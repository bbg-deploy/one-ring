require 'factory_girl'

FactoryGirl.define do
  factory :alerts_list, class: AlertsList do
    customer { |a| a.association(:customer) }
    mail "1"
    email "1"
    sms "0"
    phone "0"
  end

  factory :alerts_list_attributes_hash, class: Hash do
    customer { |a| a.association(:customer) }
    mail "1"
    email "1"
    sms "0"
    phone "0"

    initialize_with { attributes }
  end
end