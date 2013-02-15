require 'factory_girl'

FactoryGirl.define do
  factory :employee_role, class: EmployeeRole do
    sequence(:name) { |n| "employee_role_#{n}" }
  end

  factory :employee_role_attributes_hash, class: Hash do
    sequence(:name) { |n| "hashed_employee_role_#{n}" }

    initialize_with { attributes }
  end
end