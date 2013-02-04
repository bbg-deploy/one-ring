require 'spec_helper'

describe AnalystRole, :analyst => true do
  # Model & Factory Validation
  #----------------------------------------------------------------------------
  describe "factory validation", :factory_validation => true do
    specify { AnalystRole.new.should be_an_instance_of(AnalystRole) }
    specify { expect { FactoryGirl.create(:analyst_role) }.to_not raise_error }
  end

  # Associations
  #----------------------------------------------------------------------------
  describe "associations", :associations => true do
    describe "admins" do
      it "doesn't require admin presence" do
        analyst_role = FactoryGirl.create(:analyst_role, :number_of_analysts => 0)
        analyst_role.should be_valid
        analyst_role.analysts.count.should eq(0)
      end
      
      it "successfully associates admins" do
        analyst_role = FactoryGirl.create(:analyst_role, :number_of_analysts => 4)
        analyst_role.should be_valid
        analyst_role.analysts.count.should eq(4)
      end
    end    
  end

  # Attributes
  #----------------------------------------------------------------------------
  describe "attributes", :attributes => true do
    describe "name" do
      it_behaves_like "attr_accessible", :analyst_role, :name,
        ["role", "role_one", "more_descriptive_role"], #Valid values
        [nil, "!", "role2", "Role_Two"] #Invalid values
    end
    
    describe "description" do
      it_behaves_like "attr_accessible", :analyst_role, :description,
        ["demo description", "Lorem Ipsum!"], #Valid values
        [nil] #Invalid values
    end
  
    describe "permanent" do
      it_behaves_like "attr_accessible", :analyst_role, :permanent,
        [true, false], #Valid values
        [nil] #Invalid values
    end  
  end
  
  # Behaviors
  #----------------------------------------------------------------------------
  describe "behavior", :behavior => true do
    describe "to_s" do
      it "returns name as to_s" do
        analyst_role = FactoryGirl.create(:analyst_role, :name => "test_name")
        analyst_role.to_s.should eq("test_name")
      end
    end
  end
end
