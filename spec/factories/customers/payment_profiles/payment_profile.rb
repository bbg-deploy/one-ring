require 'factory_girl'

FactoryGirl.define do
  factory :payment_profile, class: PaymentProfile do
    ignore do
      with_billing_address    true
      with_credit_card        true
      with_bank_account       true

      billing_address_factory :billing_address
      credit_card_factory     :credit_card
      bank_account_factory    :bank_account
    end

    customer { |a| a.association(:customer) }
    payment_type "credit_card" #or "bank_account"
    sequence(:cim_customer_payment_profile_id) { |n| "102#{n}" } 

    # Account Holder Details
    first_name "John"
    last_name "Smith"

    after(:build) do |payment_profile, evaluator|
      if (evaluator.with_billing_address)
        payment_profile.billing_address = FactoryGirl.build(evaluator.billing_address_factory, :addressable => payment_profile)
      end
      
      if (evaluator.with_credit_card)
        payment_profile.credit_card = FactoryGirl.build(evaluator.credit_card_factory, :payment_profile => payment_profile)
      end

      if (evaluator.with_bank_account)
        payment_profile.bank_account = FactoryGirl.build(evaluator.bank_account_factory, :payment_profile => payment_profile)
      end
    end
  end

  factory :invalid_payment_profile, parent: :payment_profile do
    payment_type "invalid"
  end

  factory :payment_profile_no_id, parent: :payment_profile do
    cim_customer_payment_profile_id nil 
  end

  factory :credit_card_payment_profile, parent: :payment_profile do
    ignore do
      with_credit_card       true
      credit_card_factory    :credit_card
    end

    payment_type "credit_card"

    after(:build) do |payment_profile, evaluator|
      if (evaluator.with_credit_card)
        payment_profile.credit_card = FactoryGirl.build(evaluator.credit_card_factory, :payment_profile => payment_profile)
      end
    end
  end

  factory :invalid_credit_card_payment_profile, parent: :payment_profile do
    ignore do
      with_credit_card       true
      credit_card_factory    :invalid_credit_card
    end

    payment_type "credit_card"

    after(:build) do |payment_profile, evaluator|
      if (evaluator.with_credit_card)
        payment_profile.credit_card = FactoryGirl.build(evaluator.credit_card_factory, :payment_profile => payment_profile)
      end
    end
  end

  factory :bank_account_payment_profile, parent: :payment_profile do
    ignore do
      with_bank_account       true
      bank_account_factory    :bank_account
    end

    payment_type "bank_account"

    after(:build) do |payment_profile, evaluator|
      if (evaluator.with_bank_account)
        payment_profile.bank_account = FactoryGirl.build(evaluator.bank_account_factory, :payment_profile => payment_profile)
      end
    end
  end

  factory :invalid_bank_account_payment_profile, parent: :payment_profile do
    ignore do
      with_bank_account       true
      bank_account_factory    :invalid_bank_account
    end

    payment_type "bank_account"

    after(:build) do |payment_profile, evaluator|
      if (evaluator.with_bank_account)
        payment_profile.bank_account = FactoryGirl.build(evaluator.bank_account_factory, :payment_profile => payment_profile)
      end
    end
  end


end