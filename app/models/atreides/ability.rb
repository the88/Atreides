class Atreides::Ability
  include CanCan::Ability

  # Define abilities for the passed in user here. For example:
  # doc: https://github.com/ryanb/cancan/wiki/Defining-Abilities
  def initialize(user)
    user ||= Atreides::User.new
    if user.admin?
      can :manage, :all
    elsif user.role == :editor
      can :read, :all
      can :manage, Atreides::Post
      can :manage, Atreides::Page
    elsif user.role == :writer
      can :read, :all
      can :create, Atreides::Page
      can :create, Atreides::Post
      can :manage, Atreides::Page, :author => user
      can :manage, Atreides::Post, :author => user
    end
  end

  include Atreides::Extendable
end
