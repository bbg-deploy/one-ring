require 'factory_girl'

FactoryGirl.define do
  factory :analyst_role, class: AnalystRole do
    ignore do
      number_of_analysts  3
      analyst_factory :analyst
    end

    sequence(:name) {|n| "analyst_role_#{n.to_words.parameterize.underscore}" }
    description "Analyst role description"
    permanent true

    after(:build) do |analyst_role, evaluator|
      evaluator.number_of_analysts.times do
        analyst_role.analysts << FactoryGirl.create(evaluator.analyst_factory)
      end
    end
  end
end