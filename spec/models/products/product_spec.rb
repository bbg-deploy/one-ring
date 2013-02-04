require 'spec_helper'

describe Product do
  # Model & Factory Validation
  #----------------------------------------------------------------------------
  describe "factory validation", :factory_validation => true do
    specify { Product.new.should be_an_instance_of(Product) }
    specify { expect { FactoryGirl.create(:product) }.to_not raise_error }
  
    let(:product) { FactoryGirl.create(:product) }
    specify { product.should be_valid }
    specify { product.product_categories.should_not be_empty }
    it "should be listed in the categorizations table" do
      product.reload
      Categorization.where(:product_id => product.id).should_not be_empty
    end
  end
  
  # Associations
  #----------------------------------------------------------------------------
  describe "associations", :associations => true do    
    describe "lease" do
      it_behaves_like "required belongs_to", :product, :lease_application
      it_behaves_like "immutable belongs_to", :product, :lease_application
      it_behaves_like "deletable belongs_to", :product, :lease_application
    end

    describe "product_category" do
      it "cannot be save without a product category" do
        expect { FactoryGirl.create(:product, number_of_product_categories: 0) }.to raise_error
      end
    end
  end

  # Attributes
  #----------------------------------------------------------------------------
  describe "attributes", :attributes => true do    
    describe "name" do
      it_behaves_like "attr_accessible", :product, :name,
        ["Table", "CHair", "rANDOM ProDUCt"], #Valid values
        [nil] #Invalid values
    end

    describe "price" do
      it_behaves_like "attr_accessible", :product, :price,
        [PRODUCT_MINIMUM_PRICE, PRODUCT_MAXIMUM_PRICE, (PRODUCT_MAXIMUM_PRICE - 1), (PRODUCT_MINIMUM_PRICE + 1)], #Valid values
        [nil, -0.01, (PRODUCT_MAXIMUM_PRICE + 1), (PRODUCT_MINIMUM_PRICE - 1)] #Invalid values
    end
  
    describe "description" do
      it_behaves_like "attr_accessible", :product, :description,
        ["Lorem Ipsum", "Test Description"], #Valid values
        [nil] #Invalid values
    end
  end
  
  # Behavior
  #----------------------------------------------------------------------------
  describe "behavior", :behavior => true do
    describe "round_price" do
      it "rounds up to two decimal places" do
        product = FactoryGirl.create(:product, :price => 98.765)
        product.price.should eq(BigDecimal.new("98.77"))
      end
  
      it "rounds down to two decimal places" do
        product = FactoryGirl.create(:product, :price => 98.761)
        product.price.should eq(BigDecimal.new("98.76"))
      end
    end
  end
end