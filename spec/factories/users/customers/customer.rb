require 'factory_girl'

FactoryGirl.define do
  factory :customer, class: Customer do
    ignore do
      with_mailing_address   true
      mailing_address_factory :mailing_address

      with_phone_number   true
      phone_number_factory :phone_number
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

  factory :customer_with_lease_applications, parent: :customer do
    ignore do
      number_of_unclaimed_lease_applications   1
      number_of_claimed_lease_applications     1
      number_of_submitted_lease_applications   1
      number_of_approved_lease_applications    1
      number_of_denied_lease_applications      1
      
      unclaimed_lease_application_factory :unclaimed_lease_application
      claimed_lease_application_factory   :claimed_lease_application
      submitted_lease_application_factory :submitted_lease_application
      approved_lease_application_factory  :approved_lease_application
      denied_lease_application_factory    :denied_lease_application
    end

    after(:create) do |customer, evaluator|
      evaluator.number_of_unclaimed_lease_applications.times do
        FactoryGirl.create(evaluator.unclaimed_lease_application_factory, :matching_email => customer.email)
      end

      evaluator.number_of_claimed_lease_applications.times do
        customer.lease_applications << FactoryGirl.create(evaluator.claimed_lease_application_factory, :customer => customer)
      end

      evaluator.number_of_submitted_lease_applications.times do
        customer.lease_applications << FactoryGirl.create(evaluator.submitted_lease_application_factory, :customer => customer)
      end

      evaluator.number_of_approved_lease_applications.times do
        customer.lease_applications << FactoryGirl.create(evaluator.approved_lease_application_factory, :customer => customer)
      end

      evaluator.number_of_denied_lease_applications.times do
        customer.lease_applications << FactoryGirl.create(evaluator.denied_lease_application_factory, :customer => customer)
      end
    end    
  end
end