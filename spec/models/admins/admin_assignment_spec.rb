require 'spec_helper'

describe AdminAssignment, :admin => true do
  # Model & Factory Validation
  #----------------------------------------------------------------------------
  describe "factory validation", :factory_validation => true do
    specify { AdminAssignment.new.should be_an_instance_of(AdminAssignment) }

    describe "admin_assignment factory" do
      let(:admin_assignment) { FactoryGirl.create(:admin_assignment) }

      it_behaves_like "valid record", :admin_assignment
      
      it "has admin" do
        admin_assignment.admin.should_not be_nil
      end

      it "has admin_role" do
        admin_assignment.admin_role.should_not be_nil
      end
    end  
  end
  
  # Associations
  #----------------------------------------------------------------------------
  describe "associations", :associations => true do
    describe "admin" do
      it_behaves_like "required belongs_to", :admin_assignment, :admin
      it_behaves_like "immutable belongs_to", :admin_assignment, :admin
      it_behaves_like "deletable belongs_to", :admin_assignment, :admin
    end
  
    describe "admin_role" do
      it_behaves_like "required belongs_to", :admin_assignment, :admin_role
      it_behaves_like "immutable belongs_to", :admin_assignment, :admin_role
      it_behaves_like "deletable belongs_to", :admin_assignment, :admin_role
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
      let(:admin)      { FactoryGirl.create(:admin) }
      let(:admin_role) { FactoryGirl.create(:admin_role) }
      
      it "creates admin_assignments" do
        admin.admin_roles << admin_role
        assignments = AdminAssignment.where(:admin => admin, :admin_role => admin_role)
        assignments.should_not be_nil
      end
    end
  end
end