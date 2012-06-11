class Atreides::Page < Atreides::Base

  include Atreides::Base::Taggable
  include Atreides::Base::AasmStates
  include Atreides::Base::Validation

  #
  # Constants
  #

  #
  # Associatons
  #
  belongs_to :site, :class_name => "Atreides::Site"
  belongs_to :author, :class_name => "Atreides::User"
  belongs_to :last_editor, :class_name => "Atreides::User"
  has_many :photos, :as => :photoable, :order => "display_order", :class_name => "Atreides::Photo"
  has_many :messages, :as => :messagable, :class_name => "Atreides::Message"

  #
  # Behaviours
  #

  accepts_nested_attributes_for :messages
  accepts_nested_attributes_for :photos, :allow_destroy => true

  #
  # Validations
  #
  validate :site_id, :presence => true
  validates_presence_of :title, :body, :slug, :unless => :pending?
  validate :slug, :uniqueness => true, :if => :slug?, :scope => :site_id

  #
  # Scopes
  #
  scope :roots, where(:parent_id => nil)

  #
  # Callbacks
  #
  before_validation :update_slug

  def update_slug
    # Set slug if not set or changed
    self.slug = title.to_s.parameterize if !slug? or (!new_record? && title_changed?)
  end

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

  def thumbnail(size = :thumb)
    # Find the first thumbnail image
    url = nil
    url = photos.first.image.url(size) unless photos.empty?
    url || "/images/missing_thumb.png"
  end


  def children
    @children ||= self.class.find_all_by_parent_id(id)
  end

  def parent
    @parent ||= parent_of
  end

  def parents
    @parents ||= []
    return @parents unless @parents.empty?

    prnt = self
    while prnt.parent_id?
      prnt = parent_of(prnt)
      @parents << prnt
    end
    @parents
  end

  def root()
    return @root unless @root.nil?
    prnt = self.parent || self
    while prnt.parent_id?
      prnt = parent_of(prnt)
    end
    @root = prnt
  end

  private

  def do_publish
    update_attribute :published_at, Time.zone.now
  end

  def parent_of(page = self)
    page.parent_id? ? self.class.find(page.parent_id) : nil
  end

  include Atreides::Extendable
end
