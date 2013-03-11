require 'factory_girl'

FactoryGirl.define do
  factory :debit, class: Debit do
    ignore do
      number_of_entries  0
      entry_factory :transaction
    end

    ledger { |a| a.association(:ledger) }
    type 'Fee'
    amount BigDecimal.new("50.00")
    date { 1.day.ago }
    due_date {15.days.from_now}

    after(:create) do |credit, evaluator|
      evaluator.number_of_entries.times do
        credit.entries << FactoryGirl.create(evaluator.transaction_factory, :creditable => credit, :amount => BigDecimal.new("41.20"))        
      end
    end
  end

  factory :debit_attributes_hash, class: Hash do
    ledger { |a| a.association(:ledger) }
    type 'Fee'
    amount BigDecimal.new("10.00")
    date { 1.day.ago }
    due_date {15.days.from_now}

    initialize_with { attributes }    
  end
end