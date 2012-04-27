class Atreides::Order < Atreides::Base

  #
  # Constants
  #
  BILLING_COLS = %w(zip country street city province).freeze

  #
  # Behaviours
  #
  composed_of :amount, :class_name => "Money", :mapping => [%w(amount_cents cents), %w(currency currency)]
  composed_of :discount, :class_name => "Money", :mapping => [%w(discount_cents cents), %w(currency currency)]
  composed_of :final_amount, :class_name => "Money", :mapping => [%w(final_amount_cents cents), %w(currency currency)]

  serialize :gateway_data

  attr_accessor :card_type, :card_number, :card_verification, :card_expires_on

  #
  # States
  #
  require 'aasm'
  include ::AASM
  aasm_column :state
  aasm_initial_state :pending
  aasm_state :pending
  aasm_state :completed
  aasm_state :failed

  aasm_event :complete do
    transitions :from => [:pending], :to => :completed
  end

  aasm_event :fail do
    transitions :from => [:pending, :failed], :to => :failed
  end

  #
  # Associatons
  #
  belongs_to :user
  has_many :line_items
  has_many :products, :through => :line_items

  #
  # Validations
  #
  validates_numericality_of :amount_cents, :greater_than => 0
  validates_numericality_of :discount_cents, :greater_than_or_equal_to => 0
  validates_numericality_of :final_amount_cents, :greater_than_or_equal_to => 0
  validates_presence_of :user, :email, :first_name, :last_name, :zip, :currency, :country, :street, :city, :province, :ip_address, :products

  #
  # Scopes
  #
  default_scope order('created_at DESC')

  scope :by_month, lambda { |month|
    where("MONTH(created_at) = ?", month.to_i)
  }

  scope :by_year, lambda { |year|
    where("YEAR(created_at) = ?", year.to_i)
  }

  #
  # Callbacks
  #
  after_create :do_gateway_payment
  after_create :reduce_qty
  before_validation :total_amounts, :on => :create

  #
  # Class Methods
  #
  class << self
    def build_order_for_user(user)
      # Get address info if user has previous orders
      attrs = {}
      if old_order = user.orders.first
        old_order.attributes.each{|k,v| attrs[k] = v if BILLING_COLS.include?(k) }
      end

      # Build new object
      new(attrs.update({
        :user       => user,
        :first_name => user.first_name,
        :last_name  => user.last_name,
        :line_items => user.cart_items,
        :amount     => Money.new(user.cart_items.sum(:price_cents)),
        :ip_address => user.current_login_ip
      }))
    end
  end

  #
  # Instance Methods
  #
  def full_name
    [first_name, last_name].join(' ')
  end

  def number
    # TODO: Format this as something more user friendly
    [id, created_at].map(&:to_i).join('-')
  end

  def address
    %w(street city province zip country).map{|f| self.send(f) }.compact.join("\n")
  end

  def total_amounts
    # Set price
    self.amount = line_items.to_a.sum{ |i| i.total_price }

    # Set final amount to be paid
    self.final_amount = amount - discount
  end

  private

  def reduce_qty
    sold_outs = []
    line_items.each do |l|
      if product_size = l.product.sizes.detect{|s| s.name == l.size }
        product_size.increment!(:qty, -1)
        if product_size.qty.zero?
          sold_outs << product_size.product
        end
      end
    end

    # Mail admin if sold out
    Notifier.deliver_sold_out_warning(sold_outs) if !sold_outs.empty?
  end

  def do_gateway_payment
    # we set the serials first to raise error before payment
    auth = gateway.authorize(final_amount, credit_card, purchase_options)

    raise auth.message unless auth.success?

    # Authorization is zero if account is globally in test mode, you cannot capture:
    unless auth.authorization == "0"
      capture = gateway.capture(price, capture.authorization) #, purchase_options) 
    end

    update_attribute(:gateway_data, capture)

    capture.success? ? complete! : fail!
    capture.success?
  end

  def purchase_options
    options = {
      :order_id => id,
      :ip => ip_address,
      :customer => full_name,
      :invoice => number,
      :merchant => Settings.app_name,
      :description => "#{Settings.domain}: Purchase of #{products.map(&:title).join(', ')}",
      :email => email,
      :currency => currency,
      :billing_address => {
        :name     => full_name,
        :city     => city,
        :state    => province,
        :country  => country,
        :zip      => zip,
        :address1 => street
      }
    }
    options[:test] = true if Rails.env.development?
    options
  end

  def credit_card
    @credit_card ||= ActiveMerchant::Billing::CreditCard.new(
      :type               => card_type,
      :number             => card_number,
      :verification_value => card_verification,
      :month              => card_expires_on.month,
      :year               => card_expires_on.year,
      :first_name         => first_name,
      :last_name          => last_name
    )
  end

  def validate_card
    unless credit_card.valid?
      credit_card.errors.full_messages.each do |message|
        errors.add(:base, message)
      end
    end
  end

  def gateway
    ActiveMerchant::Billing::Base.mode = Rails.env.production? ? :production : :test
    if Rails.env.test? || Rails.env.development?
      ActiveMerchant::Billing::BogusGateway.new
    else
      ActiveMerchant::Billing::AuthorizeNetGateway.new({
        :login => Settings.paypal.login,
        :password => Settings.paypal.password})
    end
  end

  include Atreides::Extendable
end