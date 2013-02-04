require 'spec_helper'

describe Categorization do
  # Model & Factory Validation
  #----------------------------------------------------------------------------
  describe "factory validation", :factory_validation => true do
    specify { Categorization.new.should be_an_instance_of(Categorization) }
    specify { expect { FactoryGirl.create(:categorization) }.to_not raise_error }
  
    let(:categorization) { FactoryGirl.create(:categorization) }
    specify { categorization.should be_valid }
    specify { categorization.product.should_not be_nil }
    specify { categorization.product_category.should_not be_nil }
  end

  # Associations
  #----------------------------------------------------------------------------
  describe "associations", :associations => true do
    describe "product" do
      it_behaves_like "required belongs_to", :categorization, :product
      it_behaves_like "immutable belongs_to", :categorization, :product
      it_behaves_like "deletable belongs_to", :categorization, :product
    end
  
    describe "product_category" do
      it_behaves_like "required belongs_to", :categorization, :product_category
      it_behaves_like "immutable belongs_to", :categorization, :product_category
      it_behaves_like "deletable belongs_to", :categorization, :product_category
    end
  end

  # Attributes
  #----------------------------------------------------------------------------
  describe "attributes", :attributes => true do
  end

  # Behavior
  #----------------------------------------------------------------------------
  describe "behavior", :behavior => true do
    describe "automatic creation" do
      let(:product)          { FactoryGirl.create(:product) }
      let(:product_category) { FactoryGirl.create(:product_category) }
  
      it "creates categorizations" do
        product.product_categories << product_category
        categorizations = Categorization.where(:product => product, :product_category => product_category)
        categorizations.should_not be_nil
      end
    end    
  end
end