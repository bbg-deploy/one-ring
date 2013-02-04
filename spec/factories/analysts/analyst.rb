require 'factory_girl'

FactoryGirl.define do
  factory :analyst, class: Analyst do
    ignore do
      number_of_analyst_roles  1
      analyst_role_factory :analyst_role
    end

    sequence(:username) {|n| "analyst_#{n}" }
    password "fakepass"
    password_confirmation { password }
    email { "#{username}@credda.com" }
    email_confirmation { email }
    first_name "Nate"
    middle_name "TheAnalyst"
    last_name "Silver"
    date_of_birth 35.years.ago
    terms_agreement "1"

    after(:build) do |analyst, evaluator|
      evaluator.number_of_analyst_roles.times do
        analyst.analyst_roles << FactoryGirl.create(evaluator.analyst_role_factory, :number_of_analysts => 0)
      end
    end
  end

  factory :invalid_analyst, parent: :analyst do
    password "validpass"
    password_confirmation "invalidpass"
  end
end