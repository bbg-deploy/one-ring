require 'factory_girl'

FactoryGirl.define do
  factory :client, class: Client do
    sequence(:name) { |n| "client_#{n}" }
    sequence(:app_id, 1000) { |n| "app_id_#{n}" }
    app_id_confirmation { app_id }
  end

  factory :client_attributes_hash, class: Hash do
    sequence(:name) { |n| "hashed_client_#{n}" }
    sequence(:app_id, 1000) { |n| "hashed_app_id_#{n}" }
    app_id_confirmation { app_id }

    initialize_with { attributes }
  end
end