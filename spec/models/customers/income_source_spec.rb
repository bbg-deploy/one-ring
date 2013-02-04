require 'spec_helper'

describe IncomeSource do
  # Model & Factory Validation
  #----------------------------------------------------------------------------
  describe "factory validation", :factory_validation => true do
    specify { IncomeSource.new.should be_an_instance_of(IncomeSource) }

    it_behaves_like "valid record", :income_source
  end
 
  # Associations
  #----------------------------------------------------------------------------
  describe "associations", :associations => true do
    describe "customer" do
      it_behaves_like "immutable belongs_to", :income_source, :customer
      it_behaves_like "deletable belongs_to", :income_source, :customer
    end    
  end

  # Attributes
  #----------------------------------------------------------------------------
  describe "attributes", :attributes => true do  
    describe "name" do
      it_behaves_like "attr_accessible", :income_source, :name,
        ["full_time", "part_time", "disability"], #Valid values
        ["other", nil] #Invalid values
    end
  end

  # Behavior
  #----------------------------------------------------------------------------
  describe "behavior", :behavior => true do
  end
end