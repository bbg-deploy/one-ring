require 'factory_girl'

FactoryGirl.define do
  factory :credit_decision, class: CreditDecision do
    application { |a| a.association(:submitted_application) }
    status "pending"
  end

  factory :approved_credit_decision, parent: :credit_decision do
    status "approved"
  end

  factory :denied_credit_decision, parent: :credit_decision do
    status "denied"
  end

  factory :credit_decision_attributes_hash, class: Hash do
    application { |a| a.association(:submitted_application) }

    initialize_with { attributes }    
  end
end