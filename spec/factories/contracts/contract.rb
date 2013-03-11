require 'factory_girl'

FactoryGirl.define do
  factory :contract, class: Contract do
    customer_account_number { 'CUS' + SecureRandom.hex(5).upcase }
    application_number { 'APP' + SecureRandom.hex(5).upcase }
    contract_number { 'CON' + SecureRandom.hex(5).upcase }
  end

  factory :contract_attributes_hash, class: Hash do
    customer_account_number { 'CUS' + SecureRandom.hex(5).upcase }
    application_number { 'APP' + SecureRandom.hex(5).upcase }
    contract_number { 'CON' + SecureRandom.hex(5).upcase }
    
    initialize_with { attributes }    
  end
end