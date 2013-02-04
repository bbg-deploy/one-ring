require 'factory_girl'

FactoryGirl.define do
  factory :admin_role, class: AdminRole do
    ignore do
      number_of_admins  3
      admin_factory :admin
    end

    sequence(:name) {|n| "admin_role_#{n.to_words.parameterize.underscore}" }
    description "Admin role description"
    permanent true

    after(:build) do |admin_role, evaluator|
      evaluator.number_of_admins.times do
        admin_role.admins << FactoryGirl.build_stubbed(evaluator.admin_factory)
      end
    end
  end
end