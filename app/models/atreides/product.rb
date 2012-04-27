class Atreides::Product < Atreides::Base

  #
  # Constants
  #

  #
  # Associatons
  #
  has_many :photos, :as => :photoable, :order => "display_order"
  has_many :line_items
  has_many :orders, :through => :line_items
  has_many :sizes, :order => "display_order"
  
  #
  # Behaviours
  #
  include Atreides::Base::Taggable
  include Atreides::Base::AasmStates
  composed_of :price, :class_name => "Money", :mapping => [%w(price_cents cents), %w(price_currency currency)]
  accepts_nested_attributes_for :photos, :allow_destroy => true
  accepts_nested_attributes_for :sizes, :allow_destroy => true, :reject_if => Proc.new {|s| s['name'].blank? }

  #
  # Validations
  #
  validates_presence_of :title, :body, :slug, :unless => :pending?
  validates_uniqueness_of :slug, :unless => :pending?
  validates_associated :sizes
  validates_numericality_of :price_cents

  validate :check_price, :on => :update

  def check_price
    errors.add(:price, "must be greater than zero") if price.zero? and !pending?
  end

  #
  # Scopes
  #

  #
  # Callbacks
  #
  before_validation :set_slug

  def set_slug
    # Set slug
    self.slug = title.to_s.parameterize if !slug?
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
  def size_for_name(name)
    sizes.first(:conditions => {:name => name})
  end

  def sold_out?
    self.sizes.sum(:qty).zero?
  end

  private

  include Atreides::Extendable
end