require 'factory_girl'

FactoryGirl.define do
  factory :terms_option, class: TermsOption do
    application { |a| a.association(:submitted_application) }
    payment_frequency "weekly"
    markup BigDecimal.new("1.95")
    number_of_payments 10
    payment_amount BigDecimal.new("342.00")
  end

  factory :terms_option_attributes_hash, class: Hash do
    application { |a| a.association(:submitted_application) }
    payment_frequency "weekly"
    markup BigDecimal.new("1.95")
    number_of_payments 10
    payment_amount BigDecimal.new("342.00")

    initialize_with { attributes }    
  end
end