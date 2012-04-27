class Atreides::Vote < Atreides::Base

  #
  # Constants
  #

  #
  # Associatons
  #
  belongs_to :votable, :polymorphic => true
  belongs_to :user

  #
  # Validations
  #
  validates_presence_of :value, :votable, :ip
  validates_numericality_of :value, :greater_than_or_equal_to => 0
  validates_uniqueness_of :user_id, :scope => [:votable_type, :votable_id]
  validates_uniqueness_of :ip, :scope => [:votable_type, :votable_id]

  #
  # Scopes
  #

  #
  # Class Methods
  #
  class << self
  end

  #
  # Instance Methods
  #
  def yes!
    update_attributes!(:value => 1)
  end
  
  def no!
    update_attributes!(:value => 0)
  end

  include Atreides::Extendable
end