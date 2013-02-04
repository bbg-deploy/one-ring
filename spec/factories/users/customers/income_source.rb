require 'factory_girl'

FactoryGirl.define do
  factory :income_source, class: IncomeSource do
    customer { |a| a.association(:customer) }
    name "full_time"
    employer_name "Nineteen Ventures, LLC"
    employer_phone_number "703-309-1874"
    monthly_income BigDecimal.new("1050.00")
  end
end