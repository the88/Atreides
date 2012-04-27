class Atreides::Size < Atreides::Base

  #
  # Constants
  #

  #
  # Associatons
  #
  belongs_to :product

  #
  # Validations
  #
  validates_presence_of :name, :qty
  validates_uniqueness_of :name, :scope => :product_id, :message => "can only be used once per product", :if => :product_id?
  validates_numericality_of :qty, :greater_than_or_equal_to => 0
  validates_numericality_of :display_order

  #
  # Scopes
  #
  
  #
  # Callbacks
  #

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

  include Atreides::Extendable
end
