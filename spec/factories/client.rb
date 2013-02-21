require 'factory_girl'

FactoryGirl.define do
  factory :client, class: Client do
    sequence(:name) { |n| "client_#{n}" }
    sequence(:redirect_uri, 1000) { |n| "http://www.testuri#{n}.com" }
  end

  factory :client_attributes_hash, class: Hash do
    sequence(:name) { |n| "hashed_client_#{n}" }
    sequence(:redirect_uri, 1000) { |n| "http://www.hasheduri#{n}.com" }

    initialize_with { attributes }
  end
end