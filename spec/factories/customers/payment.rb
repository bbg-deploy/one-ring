require 'factory_girl'

FactoryGirl.define do
  factory :payment, class: Payment do
    customer { |a| a.association(:customer_with_payment_profiles) }
    payment_profile { customer.payment_profiles.first }
    amount BigDecimal.new("41.10")
  end

  factory :payment_attributes_hash, class: Hash do
    customer { |a| a.association(:customer_with_payment_profiles) }
    payment_profile_id { customer.payment_profiles.first.id }
    amount BigDecimal.new("41.10")

    initialize_with { attributes }    
  end
end