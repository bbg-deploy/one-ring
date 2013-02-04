class CustomerAbility
  include CanCan::Ability

  def initialize(customer)
    if customer.nil?
      can :manage, :all
    else
      #TODO: Is this necessary for Devise?
      can [:read, :update], Customer, :id => customer.id
      can [:read, :claim, :edit, :apply, :submit, :select, :finalize], Lease#, :customer => [customer, nil]
      can :manage, PaymentProfile, :customer => customer
#      can [:read, :create], Payment
      can :manage, Payment
    end
  end  
end