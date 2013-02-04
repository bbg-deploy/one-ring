require 'spec_helper'

describe ProductCategory do
  # Model & Factory Validation
  #----------------------------------------------------------------------------
  describe "factory validation", :factory_validation => true do
    specify { ProductCategory.new.should be_an_instance_of(ProductCategory) }
    specify { expect { FactoryGirl.create(:product_category) }.to_not raise_error }
  
    let(:product_category) { FactoryGirl.create(:product_category) }
    specify { product_category.should be_valid }
    specify { product_category.products.should_not be_empty }
    it "should be listed in the categorizations table" do
      product_category.reload
      Categorization.where(:product_category_id => product_category.id).should_not be_empty
    end
  end
    
  # Associations
  #----------------------------------------------------------------------------
  describe "associations", :associations => true do
  end

  # Attributes
  #----------------------------------------------------------------------------
  describe "attributes", :attributes => true do
    describe "name" do
      it_behaves_like "attr_accessible", :product_category, :name,
        ["Tables", "CHairS", "rANDOM CateGORY"], #Valid values
        [nil] #Invalid values
    end
  end
    
  # Behavior
  #----------------------------------------------------------------------------
  describe "behavior", :behavior => true do
    describe "nested set" do
      it "root behavior" do
        product_category = FactoryGirl.create(:product_category)
        product_category.root?.should eq(true)
      end
  
      it "ancestry behavior" do
        grandparent = FactoryGirl.create(:product_category)
        parent = FactoryGirl.create(:product_category)
        child = FactoryGirl.create(:product_category)
        parent.move_to_child_of(grandparent)
        child.move_to_child_of(parent)
        grandparent.reload
        
        child.child?.should eq(true)
        parent.is_ancestor_of?(child).should eq(true)
        grandparent.is_ancestor_of?(parent).should eq(true)
      end
  
      it "leaf behavior" do
        grandparent = FactoryGirl.create(:product_category)
        parent = FactoryGirl.create(:product_category)
        child = FactoryGirl.create(:product_category)
        parent.move_to_child_of(grandparent)
        child.move_to_child_of(parent)
        grandparent.reload
        
        child.leaf?.should eq(true)
        grandparent.leaf?.should eq(false)
  
        child.root?.should eq(false)
        grandparent.root?.should eq(true)
      end
    end
  end
end