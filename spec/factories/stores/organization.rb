require 'factory_girl'

FactoryGirl.define do
  factory :organization, class: Organization do
    ignore do
      number_of_stores     1
      store_factory :store
    end

    sequence(:name) {|n| "organization_#{n}" }
    website { "www.#{name}.com" }

    after(:create) do |organization, evaluator|
      evaluator.number_of_stores.times do
        organization.stores << FactoryGirl.create(evaluator.store_factory, :organization => organization)
      end
    end
  end

  factory :organization_attributes_hash, class: Hash do
    sequence(:name) {|n| "hashed_organization_#{n}" }
    website { "www.#{name}.com" }

    initialize_with { attributes }
  end
end