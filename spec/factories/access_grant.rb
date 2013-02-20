require 'factory_girl'

FactoryGirl.define do
  factory :access_grant, class: AccessGrant do
    accessible {|a| a.association(:customer)}
    client {|a| a.association(:client)}
    code "12345678"
    access_token { SecureRandom.hex }
    refresh_token { SecureRandom.hex }
    access_token_expires_at { 3.hours.from_now }
  end
end