class AnonymousAbility
  include CanCan::Ability

  def initialize
    can :manage, :none
  end
end