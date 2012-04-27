class Atreides::Photo < Atreides::Base

  #
  # Constants
  #

  #
  # Behaviours
  #
  serialize :sizes

  # Regen thumbs with rake paperclip:refresh CLASS=Atreides::Photo or .reprocess!
  has_attached_file :image,
    :styles           => Settings.photo_dimensions.dup.symbolize_keys,
    :storage          => Settings.s3_enabled? ? :s3 : :filesystem,
    :convert_options  => { 
      :all => Settings.photo_conv_options || "-density 72 " 
    },
    :path             => Settings.s3_enabled? ? ":attachment/:id/:style/:basename.:extension" : ":rails_root/public/system/:attachment/:id/:style/:basename.:extension",
    :s3_credentials   => (Settings.s3.symbolize_keys rescue nil),
    :bucket           => [Settings.app_name, Rails.env].join('-').parameterize.to_s,
    :log_command      => Rails.env.development?

  #
  # Callbacks
  #

  #
  # Associatons
  #
  belongs_to :photoable, :polymorphic => true, :touch => true
  has_many :features, :class_name => "Atreides::Feature"
  
  # using :dependent => :nullify just did not worked on the has_many :features association
  # so we make this to make each features clean and valid
  before_destroy :clean_features
  def clean_features
    features.each do |f|
      f.photo = nil
      f.save
    end
  end
  #
  # Validations
  #
  validates_attachment_presence :image
  validates_attachment_size :image, :less_than => 3.megabytes
  validates_presence_of :url, :unless => :image_file_name?
  validates :url, :presence => true, :url => true, :if => :url?

  #
  # Scopes
  #
  default_scope :order => "display_order asc, id desc" 

  #
  # Class Methods
  #
  class << self
    
    def base_class
      self
    end

  end

  #
  # Instance Methods
  #
  before_validation :fetch_remote_image
  before_create :add_to_queue
  after_save :update_associated_models

  def fetch_remote_image
    # If there is a URL then download it and use
    self.image = do_download_remote_image if url_changed?
  end

  def add_to_queue
    # Set the display order to be last
    self.display_order = Atreides::Photo.count(:conditions => {:photoable_id => self.photoable_id, :photoable_type => self.photoable_type})
  end

  def update_associated_models
    # Update assoc'd models
    features.update_all({:updated_at => Time.zone.now})
  end

  def size(thumb)
    sizes[thumb.to_sym]
  rescue => exception
    logger.error { "Error getting image sizes: #{exception}" }
    {}
  end

  # Overload Paperclip so that images are only resaved when it changes - uses too much memory otherwise
  def save_attached_files
    super if image_file_size_changed?
  end

  # Save the images dimensions before being sent to storage
  after_post_process :calculate_attachment_sizes
  def calculate_attachment_sizes
    if (image_file_name?)
      self.sizes = {}
      self.image.queued_for_write.each {|key,file|
        next unless File.exists?(file)
        self.sizes[key.to_sym]={}
        geo = Paperclip::Geometry.from_file(file)
        %w(width height).each{|dim|
          self.sizes[key.to_sym][dim.to_sym] = geo.send(dim.to_sym).to_i
        }
      }
    end
  end

  private

  def do_download_remote_image
    require 'open-uri'
    io = open(URI.parse(url))
    def io.original_filename; base_uri.path.split('/').last; end
    io.original_filename.blank? ? nil : io
  rescue Exception
    errors.add(:url, "not valid. Unable to download image.")
    return nil
  end

  include Atreides::Extendable
end