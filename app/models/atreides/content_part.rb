class Atreides::ContentPart < Atreides::Base

  include Atreides::Base::Validation

  #
  # Constants
  #
  @@content_types = %w(text photos videos)
  @@display_types = %w(photos gallery)

  #
  # Associatons
  #
  belongs_to :contentable, :polymorphic => true, :touch => true
  has_many :photos, :as => :photoable, :order => "display_order", :class_name => "Atreides::Photo", :dependent => :destroy
  has_many :videos, :order => "display_order", :class_name => "Atreides::Video", :dependent => :destroy

  #
  # Behaviours
  #

  #XXX acts_as_commentable
  accepts_nested_attributes_for :photos, :allow_destroy => true
  accepts_nested_attributes_for :videos, :allow_destroy => true

  #
  # Validations
  #
  validates_inclusion_of :content_type, :in => @@content_types
  validates_inclusion_of :display_type, :in => @@display_types, :if => Proc.new {|c| c.content_type? && c.content_type.photos? }
  validate :should_have_text,   :if => Proc.new {|c| c.content_type? && c.content_type.text?   }
  validate :should_have_photos, :if => Proc.new {|c| c.content_type? && c.content_type.photos? }
  validate :should_have_video,  :if => Proc.new {|c| c.content_type? && c.content_type.videos? }

  #
  # Scopes
  #

  @@content_types.each do |type|
    scope type.pluralize, where(:content_type => type.to_s)
  end

  #
  # Callbacks
  #
  after_initialize :set_display_type
  before_create :add_to_queue

  #
  # Class Methods
  #
  class << self

    def content_types
      @@content_types
    end

    def display_types
      @@display_types
    end
    
    def base_class
      self
    end

  end

  #
  # Instance Methods
  #
  def content_type
    @_content_type ||= ActiveSupport::StringInquirer.new(read_attribute(:content_type)) unless read_attribute(:content_type).blank?
  end

  def display_type
    @_display_type ||= ActiveSupport::StringInquirer.new(read_attribute(:display_type)) unless read_attribute(:display_type).blank?
  end

  def content_types
    self.class.content_types
  end

  private
  
  def add_to_queue
    # Set the display order to be last
    self.display_order ||= Atreides::ContentPart.where(:contentable_id => self.contentable_id, :contentable_type => self.contentable_type).count
  end

  def set_display_type
    self.display_type ||= @@display_types.first
  end

  def should_have_text
    errors.add(:body, "should not be empty") unless body?
  end

  def should_have_photos
    errors.add(:photos, "should not be empty") if photos.empty?
  end

  def should_have_video
    errors.add(:videos, "should not be empty") if videos.empty?
  end

  include Atreides::Extendable
end
