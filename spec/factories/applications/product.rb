require 'factory_girl'

FactoryGirl.define do
  factory :product, class: Product do
    application { |a| a.association(:unclaimed_application) }
    type 'Tire'
    name "Firestone FR710"
    price BigDecimal.new("278.10")
    id_number "TI21343#{Random.new.rand(1000)}"
  end

  factory :tire, parent: :product do
    type 'Tire'
  end

  factory :product_attributes_hash, class: Hash do
    application { |a| a.association(:unclaimed_application) }
    type 'Tire'
    name "Firestone FR710"
    price BigDecimal.new("278.10")
    id_number "TI21343#{Random.new.rand(1000)}"

    initialize_with { attributes }    
  end
end