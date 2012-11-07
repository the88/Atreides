class Atreides::User < Atreides::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable
  begin
    devise :database_authenticatable, :registerable,
           :recoverable, :rememberable, :trackable, :validatable
  rescue NoMethodError
    puts "[WARNING] The Devise initializer seems to be missing. If you are generators, this is normal."
    def self.devise *args
    end
  end

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :role


  #
  # Constants
  #

  #
  # Associatons
  #

  has_many :line_items
  has_many :cart_items, :class_name => "LineItem", :conditions => "order_id is null"
  has_many :orders
  has_many :likes
  has_many :posts, :class_name => "Atreides::Post", :through => :author_id
  has_many :pages, :class_name => "Atreides::Page", :through => :author_id

  #
  # Behvaiours
  #
  attr_accessible :first_name, :last_name
  # attr_accessible :twitter_token, :twitter_secret, :profile_pic_url, :fb_session_key

  #
  # Validations
  #
  validates :email, :presence => true, :uniqueness => true
  validates :first_name, :presence => true
  validates :last_name, :presence => true


  #
  # Callbacks
  #
  before_destroy :prevent_destroying_last_admin

  #
  # Scopes
  #
  scope :admins, lambda { where(:role => :admin) }

  #
  # Class Methods
  #
  class << self
    def build_admin props
      self.new (props || {}).merge :role => :admin
    end

    def can_destroy_admin?
      admins.count > 1
    end

    # Sort by descending order of ability
    def roles
      [:admin, :editor, :writer]
    end

    def available_roles(user)
      idx = roles.find_index(user.role.to_sym)
      idx == nil ? [] : roles[idx..-1]
    end
  end

  def prevent_destroying_last_admin
    errors.add(:base, "not allowed destroying the last administrator") unless destroyable?
    destroyable?
  end

  def destroyable?
    !admin? || self.class.admins.count > 1
  end

  def admin?
    role && role.to_sym == :admin
  end

  def role
    @role ||= (self.attributes['role'] && self.attributes['role'].to_sym)
  end

  #
  # Instance Methods
  #
  def full_name
    [first_name, last_name].join(' ')
  end

  def add_to_cart(opts = {})
    product = opts[:product]
    size = opts[:size].to_s
    qty = opts[:qty].to_i
    return if !product or !product.is_a?(Product)

    # Look for exisiting item
    item = cart_items.detect{|i|i.product==product and i.product.size_for_name(size) }

    # Create if not found
    item = cart_items.build(:product => product, :size => size) if item.nil?

    # Update qty
    item.qty += qty

    item.save
    item
  end

  protected

  def password_required?
    !persisted? || password.present? || password_confirmation.present?
  end

  include Atreides::Extendable
end
