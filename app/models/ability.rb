class Ability
  include CanCan::Ability

  def initialize(user)
   if user.kind_of? Customer
      can :manage, PaymentProfile, :customer => user
      can :create, PaymentProfile
      can :manage, Application
    elsif user.kind_of? Store
      can :manage, :none
      can :manage, Application
    elsif user.kind_of? Employee
      #TODO: Only Admins should be able to manage these
      can :manage, Client
      can :manage, Employee
      can :manage, Store
      can :manage, Application
    else
      can :manage, :none
    end
 
    # Define abilities for the passed in user here. For example:
    #
    #   user ||= User.new # guest user (not logged in)
    #   if user.admin?
    #     can :manage, :all
    #   else
    #     can :read, :all
    #   end
    #
    # The first argument to `can` is the action you are giving the user 
    # permission to do.
    # If you pass :manage it will apply to every action. Other common actions
    # here are :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on. 
    # If you pass :all it will apply to every resource. Otherwise pass a Ruby
    # class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the
    # objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details:
    # https://github.com/ryanb/cancan/wiki/Defining-Abilities
  end
end
