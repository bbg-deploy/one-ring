require 'factory_girl'

FactoryGirl.define do
  factory :phone_number, class: PhoneNumber do
    phonable {|a| a.association(:customer)}
    sequence(:phone_number, 1000) { |n| "703-430-#{n}" }
    primary true
    cell_phone true
  end

  factory :customer_phone_number, parent: :phone_number do
    phonable {|a| a.association(:customer)}
  end

  factory :store_phone_number, parent: :phone_number do
    phonable {|a| a.association(:store)}
  end

  factory :invalid_phone_number, parent: :phone_number do
    phone_number nil
  end

  factory :phone_number_attributes_hash, class: Hash do
    phonable {|a| a.association(:customer)}
    sequence(:phone_number, 1000) { |n| "703-430-#{n}" }
    primary true
    cell_phone true

    initialize_with { attributes }
  end
end