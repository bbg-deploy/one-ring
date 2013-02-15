require 'spec_helper'

describe EmployeeRole do
  # Model & Factory Validation
  #----------------------------------------------------------------------------
  describe "factory validation", :factory_validation => true do
    specify { EmployeeRole.new.should be_an_instance_of(EmployeeRole) }
  
    describe "employee_role factory" do
      it_behaves_like "valid record", :employee_role
    end

    describe "employee_attributes_hash" do
      it "creates new employee_role when passed to EmployeeRole" do
        attributes = FactoryGirl.build(:employee_role_attributes_hash)
        employee_role = EmployeeRole.create(attributes)
        employee_role.should be_valid
      end
    end
  end

  # Database
  #----------------------------------------------------------------------------
  describe "database", :database => true do
    # Account Information
    it { should have_db_column(:name) }
    it { should have_db_index(:name) }
  end

  # Associations
  #----------------------------------------------------------------------------
  describe "associations", :associations => true do
  end

  # Attributes
  #----------------------------------------------------------------------------
  describe "attributes", :attributes => true do
    before(:each) do
      attributes = FactoryGirl.build(:employee_role_attributes_hash)
      employee_role = EmployeeRole.create!(attributes) 
    end

    describe "name" do
      it { should allow_mass_assignment_of(:name) }
      it { should validate_presence_of(:name) }
      it { should validate_uniqueness_of(:name) }
      it { should allow_value("Chris", "James", "tHomAS", "isexactlytwentychars").for(:name) }
      it { should_not allow_value(nil, "!", "cat", "Chris Topher", "admin", "demo", "12Street", "ithastoomanycharacters").for(:name) }
    end
  end
  
  # Behavior
  #----------------------------------------------------------------------------
  describe "behavior", :behavior => true do
  end
end