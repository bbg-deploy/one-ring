require 'factory_girl'

FactoryGirl.define do
  factory :admin, class: Admin do
    ignore do
      number_of_admin_roles  1
      admin_role_factory :admin_role
    end

    sequence(:username) {|n| "admin_#{n}" }
    password "fakepass"
    password_confirmation { password }
    email { "#{username}@credda.com" }
    email_confirmation { email }
    first_name "John"
    middle_name "Quincy"
    last_name "Doe"
    date_of_birth 26.years.ago
    terms_agreement "1"

    after(:build) do |admin, evaluator|
      evaluator.number_of_admin_roles.times do
        admin.admin_roles << FactoryGirl.build_stubbed(evaluator.admin_role_factory, :number_of_admins => 0)
      end
    end
  end

  factory :invalid_admin, parent: :admin do
    password "validpass"
    password_confirmation "invalidpass"
  end
end