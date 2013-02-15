require 'factory_girl'

FactoryGirl.define do
  factory :bank_account, class: BankAccount do
    payment_profile { |a| a.association(:payment_profile) }
    account_holder "personal"
    account_type "checking"
    routing_number "111000025"
    account_number "123456789012"
  end

  factory :invalid_bank_account, parent: :bank_account do
    account_number nil
  end

  factory :bank_account_attributes_hash, class: Hash do
    payment_profile { |a| a.association(:payment_profile) }
    account_holder "personal"
    account_type "checking"
    routing_number "111000025"
    account_number "123456789012"

    initialize_with { attributes }
  end
end