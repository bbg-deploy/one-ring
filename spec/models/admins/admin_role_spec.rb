require 'spec_helper'

describe AdminRole, :admin => true do
  # Model & Factory Validation
  #----------------------------------------------------------------------------
  describe "factory validation", :factory_validation => true do
    specify { AdminRole.new.should be_an_instance_of(AdminRole) }

    describe "admin factory" do
      let(:admin_role) { FactoryGirl.create(:admin_role) }

      it_behaves_like "valid record", :admin_role
      
      it "has admin_assignments" do
        admin_role.admin_assignments.should_not be_empty
      end

      it "has admin_roles" do
        admin_role.admins.should_not be_empty
      end
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
      it_behaves_like "attr_accessible", :admin_role, :name,
        ["role", "role_one", "more_descriptive_role"], #Valid values
        [nil, "!", "role2", "Role_Two"] #Invalid values
    end
    
    describe "description" do
      it_behaves_like "attr_accessible", :admin_role, :description,
        ["demo description", "Lorem Ipsum!"], #Valid values
        [nil] #Invalid values
    end
  
    describe "permanent" do
      it_behaves_like "attr_accessible", :admin_role, :permanent,
        [true, false], #Valid values
        [nil] #Invalid values
    end  
  end
  
  # Behavior
  #----------------------------------------------------------------------------
  describe "behavior", :behavior => true do
    describe "to_s" do
      it "returns name as to_s" do
        admin_role = FactoryGirl.create(:admin_role, :name => "test_name")
        admin_role.to_s.should eq("test_name")
      end
    end
  end
end
