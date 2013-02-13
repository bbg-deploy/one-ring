require 'factory_girl'

FactoryGirl.define do
  factory :credit_card, class: CreditCard do
    # Credit Card Details
    payment_profile { |a| a.association(:payment_profile) }
    first_name "Tom"
    last_name "Jones"
    brand "visa"
    credit_card_number "4111111111111111"
    expiration_date { 5.years.from_now }
    ccv_number "515"
  end

  factory :visa_credit_card, parent: :credit_card do    
  end

  factory :mastercard_credit_card, parent: :credit_card do
    brand "master"
    credit_card_number "5555555555554444"
  end

  factory :amex_credit_card, parent: :credit_card do
    brand "american_express"
    credit_card_number "371449635398431"
    ccv_number "1234"
  end

  factory :discover_credit_card, parent: :credit_card do
    brand "discover"
    credit_card_number "6011111111111117"
  end

  factory :diners_club_credit_card, parent: :credit_card do
    brand "diners_club"
    credit_card_number "38520000023237"
  end

  factory :jcb_credit_card, parent: :credit_card do
    brand "jcb"
    credit_card_number "3530111333300000"
  end
  
  factory :invalid_credit_card, parent: :credit_card do
    credit_card_number nil
  end

  factory :credit_card_attributes_hash, class: Hash do
    payment_profile { |a| a.association(:payment_profile) }
    first_name "Tom"
    last_name "Jones"
    brand "visa"
    credit_card_number "4111111111111111"
    expiration_date { 5.years.from_now }
    ccv_number "515"

    initialize_with { attributes }
  end
end