require 'factory_girl'

FactoryGirl.define do
  factory :address, class: Address do
    addressable {|a| a.association(:customer)}
    address_type :mailing
    street "123 Fake St."
    city "Spartanburg"
    state "South Carolina"
    zip_code "29301"
    country "United States"
  end

  factory :mailing_address, parent: :address do
    addressable {|a| a.association(:customer)}
    address_type :mailing
  end

  factory :billing_address, parent: :address do
    addressable {|a| a.association(:payment_profile)}
    address_type :billing
  end

  factory :store_address, parent: :address do
    addressable {|a| a.association(:store)}
    address_type :store    
  end

  factory :invalid_address, parent: :address do
    street nil
    city nil
  end
end