require 'factory_girl'

FactoryGirl.define do
  factory :employee, class: Employee do
    sequence(:username) { |n| "employee_#{n}" }
    password "fakepass"
    password_confirmation { password }
    email { "#{username}@credda.com" }
    email_confirmation { email }
    first_name "John"
    middle_name "Quincy"
    last_name "Doe"
    date_of_birth { 26.years.ago }
    terms_agreement "1"
  end

  factory :invalid_employee, parent: :employee do
    password "validpass"
    password_confirmation "invalidpass"
  end

  factory :employee_attributes_hash, class: Hash do
    sequence(:username) { |n| "hashed_employee_#{n}" }
    password "fakepass"
    password_confirmation { password }
    email { "#{username}@credda.com" }
    email_confirmation { email }
    first_name "John"
    middle_name "Quincy"
    last_name "Doe"
    date_of_birth { 26.years.ago }
    terms_agreement "1"

    initialize_with { attributes }
  end
end