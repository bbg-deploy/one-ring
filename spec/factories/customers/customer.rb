require 'factory_girl'

FactoryGirl.define do
  factory :customer, class: Customer do
    ignore do
      with_mailing_address   true
      mailing_address_factory :mailing_address

      with_phone_number   true
      phone_number_factory :phone_number

      with_alerts_list   true
      alerts_list_factory :alerts_list
    end
    
    sequence(:username) { |n| "customer_#{n}" }
    password "fakepass"
    password_confirmation { password }
    email { "#{username}@notcredda.com" }
    email_confirmation { email }
    first_name "John"
    middle_name "Quincy"
    last_name "Doe"
    date_of_birth { 26.years.ago }
    sequence(:social_security_number, 1000) { |n| "387-87-#{n}" }
    sequence(:cim_customer_profile_id) { |n| "101#{n}" } 
    terms_agreement "1"

    after(:build) do |customer, evaluator|
      if (evaluator.with_mailing_address)
        customer.mailing_address = FactoryGirl.build(evaluator.mailing_address_factory, :addressable => customer)
      end

      if (evaluator.with_phone_number)
        customer.phone_number = FactoryGirl.build(evaluator.phone_number_factory, :phonable => customer)
      end

      if (evaluator.with_alerts_list)
        customer.alerts_list = FactoryGirl.build(evaluator.alerts_list_factory, :customer => customer)
      end
    end
  end

  factory :confirmed_customer, parent: :customer do
    after(:create) do |customer|
      customer.confirm!
    end
  end  

  factory :invalid_customer, parent: :customer do
    password "validpass"
    password_confirmation "invalidpass"
  end

  factory :customer_no_id, parent: :customer do
    cim_customer_profile_id nil
  end
  
  factory :customer_with_payment_profiles, parent: :customer do
    ignore do
      number_of_payment_profiles   1      
      payment_profile_factory :payment_profile
    end

    after(:create) do |customer, evaluator|
      evaluator.number_of_payment_profiles.times do
        customer.payment_profiles << FactoryGirl.create(evaluator.payment_profile_factory, :customer => customer)
      end
    end    
  end

  factory :customer_attributes_hash, class: Hash do
    sequence(:username) { |n| "hashed_customer_#{n}" }
    password "fakepass"
    password_confirmation { password }
    email { "#{username}@notcredda.com" }
    email_confirmation { email }
    first_name "John"
    middle_name "Quincy"
    last_name "Doe"
    date_of_birth { 26.years.ago }
    sequence(:social_security_number, 1000) { |n| "430-87-#{n}" }
    mailing_address_attributes { FactoryGirl.build(:address_attributes_hash, :addressable => nil).except(:addressable) }
    phone_number_attributes    { FactoryGirl.build(:phone_number_attributes_hash, :phonable => nil).except(:phonable) }
    alerts_list_attributes     { FactoryGirl.build(:alerts_list_attributes_hash, :customer => nil).except(:customer) }
    terms_agreement "1"

    initialize_with { attributes }
  end
end