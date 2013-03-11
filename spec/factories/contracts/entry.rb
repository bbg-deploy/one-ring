require 'factory_girl'

FactoryGirl.define do
  factory :entry, class: Entry do
    ledger    {|a| a.association(:ledger)}
    debit     {|a| a.association(:debit, :amount => BigDecimal.new("200.00"))}
    credit    {|a| a.association(:credit, :amount => BigDecimal.new("150.00"))}
    amount    BigDecimal.new("23.49")
    
    after(:build) do |entry|
      entry.debit.ledger = entry.ledger
      entry.credit.ledger = entry.ledger      
    end
  end
end