class StoreAbility
  include CanCan::Ability

  def initialize(store)
    if store.nil?
      can :manage, :all
    else
      can [:read, :update], Store, :id => store.id
      #TODO: Trying to restrict this to just the store's Leases is killing me.
      can [:read, :update, :edit, :create], Lease#, :store => store
    end
  end  
end