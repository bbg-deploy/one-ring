require 'factory_girl'

FactoryGirl.define do
  factory :credit, class: Credit do
    ignore do
      number_of_entries  0
      entry_factory :transaction
    end

    ledger { |a| a.association(:ledger) }
    type 'CreddaCredit'
    amount BigDecimal.new("41.10")
    date { 1.day.ago }

    after(:create) do |credit, evaluator|
      evaluator.number_of_entries.times do
        credit.entries << FactoryGirl.create(evaluator.transaction_factory, :creditable => credit, :amount => BigDecimal.new("41.20"))        
      end
    end
  end

  factory :credda_credit, parent: :credit do
    type 'CreddaCredit'
  end

  factory :credit_attributes_hash, class: Hash do
    ledger { |a| a.association(:ledger) }
    type 'CreddaCredit'
    amount BigDecimal.new("41.10")
    date { 1.day.ago }

    initialize_with { attributes }    
  end
end