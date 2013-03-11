require 'factory_girl'

FactoryGirl.define do
  factory :ledger, class: Ledger do
    contract { |a| a.association(:contract) }
    type 'FifoLedger'
  end

  factory :ledger_attributes_hash, class: Hash do
    contract { |a| a.association(:contract) }
    type 'FifoLedger'
    
    initialize_with { attributes }    
  end
end