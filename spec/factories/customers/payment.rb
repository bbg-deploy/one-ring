require 'factory_girl'

FactoryGirl.define do
  factory :payment, class: Payment do
    ignore do
      number_of_entries  0
      entry_factory :transaction
    end

    ledger { |a| a.association(:ledger) }
    cim_payment_profile_id "431234#{Random.new.rand(1000)}"
    type 'Payment'
    amount BigDecimal.new("41.10")
    date { 1.day.ago }

    after(:create) do |credit, evaluator|
      evaluator.number_of_entries.times do
        credit.entries << FactoryGirl.create(evaluator.transaction_factory, :creditable => credit, :amount => BigDecimal.new("41.20"))        
      end
    end
  end

  factory :payment_attributes_hash, class: Hash do
    ledger { |a| a.association(:ledger) }
    type 'Payment'
    amount BigDecimal.new("41.10")
    date { 1.day.ago }

    initialize_with { attributes }    
  end
end