require 'factory_girl'

FactoryGirl.define do
  factory :store, class: Store do
    ignore do
      number_of_addresses     1
      number_of_phone_numbers 1
      
      address_factory :store_address
      phone_number_factory :store_phone_number
    end

    sequence(:username) {|n| "store_#{n}" }
    password "fakepass"
    password_confirmation { password }
    email { "#{username}@notcredda.com" }
    email_confirmation { email }
    name "Widget Co."
    sequence(:employer_identification_number, 1000) { |n| "38-787#{n}" }
    terms_agreement "1"

    after(:build) do |store, evaluator|
      evaluator.number_of_addresses.times do
        store.addresses << FactoryGirl.build(evaluator.address_factory, :addressable => store)
      end

      evaluator.number_of_phone_numbers.times do
        store.phone_numbers << FactoryGirl.build(evaluator.phone_number_factory, :phonable => store)
      end
    end
  end
  
  factory :invalid_store, parent: :store do
    password "validpass"
    password_confirmation "invalidpass"
  end

  factory :store_attributes_hash, class: Hash do
    sequence(:username) {|n| "hashed_store_#{n}" }
    password "fakepass"
    password_confirmation { password }
    email { "hashed_#{username}@notcredda.com" }
    email_confirmation { email }
    name "Widget Co."
    sequence(:employer_identification_number, 1000) { |n| "41-787#{n}" }
    addresses_attributes     { { "0" => FactoryGirl.build(:store_address_attributes_hash, :addressable => nil).except(:addressable) } }
    phone_numbers_attributes { { "0" => FactoryGirl.build(:phone_number_attributes_hash, :phonable => nil).except(:phonable) } }
    terms_agreement "1"

    initialize_with { attributes }
  end
end