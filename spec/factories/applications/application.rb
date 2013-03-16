require 'factory_girl'

FactoryGirl.define do
  factory :unclaimed_application, class: Application do
    ignore do
      number_of_products  2
      product_factory :product
      product_name "Demo Product"
      product_price BigDecimal.new("299.55")
    end

    store_account_number { 'UST' + SecureRandom.hex(5).upcase }
    matching_email "matching@notcredda.com"

    after(:build) do |application, evaluator|
      evaluator.number_of_products.times do
        application.products << FactoryGirl.build(evaluator.product_factory, :application => application, :name => evaluator.product_name, :price => evaluator.product_price)
      end
    end
  end

  factory :claimed_application, parent: :unclaimed_application do
    customer_account_number { 'CUS' + SecureRandom.hex(5).upcase }

    after(:create) do |application|
      application.claim
    end
  end

  factory :submitted_application, parent: :claimed_application do
    ignore do
      number_of_income_sources  1
      income_source_factory :income_source
    end

    time_at_address { 5.years.ago }
    rent_or_own "rent"
    rent_payment BigDecimal.new("350.00")
    
    after(:build) do |application, evaluator|
#      evaluator.number_of_income_sources.times do
#        application.customer.income_sources << FactoryGirl.create(evaluator.income_source_factory, :customer => application.customer)      
#      end
    end

    after(:create) do |application|
      application.submit
    end
  end

  factory :denied_application, parent: :submitted_application do
    after(:create) do |application|
      FactoryGirl.create(:denied_credit_decision, :application => application)
      application.deny
    end
  end

  factory :approved_application, parent: :submitted_application do
    after(:create) do |application|
      FactoryGirl.create(:approved_credit_decision, :application => application)
      application.approve
    end
  end

  factory :finalized_application, parent: :approved_application do
    after(:create) do |application|
      FactoryGirl.create(:terms_option, :application => application)
      FactoryGirl.create(:terms_option, :application => application)
      FactoryGirl.create(:terms_option, :application => application)
      application.id_verified = true
      application.finalize
    end
  end

  factory :completed_application, parent: :finalized_application do
    ignore do
      with_lease true
    end

    after(:create) do |application, evaluator|
#      if (evaluator.with_lease)
#        application.lease = FactoryGirl.create(:lease, :application => application)      
#      end
      application.complete
    end
  end

  factory :application_attributes_hash, class: Hash do
    store_account_number { 'UST' + SecureRandom.hex(5).upcase }
    matching_email "matching@notcredda.com"
    products_attributes { { "0" => FactoryGirl.build(:product_attributes_hash, :application => nil).except(:application) } }

    initialize_with { attributes }
  end
end