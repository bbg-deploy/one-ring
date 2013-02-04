require 'spec_helper'

describe AnalystAssignment, :analyst => true do
  # Model & Factory Validation
  #----------------------------------------------------------------------------
  describe "factory validation", :factory_validation => true do
    specify { AnalystAssignment.new.should be_an_instance_of(AnalystAssignment) }
    specify { expect { FactoryGirl.create(:analyst_assignment) }.to_not raise_error }
  
    let(:analyst_assignment) { FactoryGirl.create(:analyst_assignment) }
    specify { analyst_assignment.should be_valid }
    specify { analyst_assignment.analyst.should_not be_nil }
    specify { analyst_assignment.analyst_role.should_not be_nil }
  end
  
  # Associations
  #----------------------------------------------------------------------------
  describe "associations", :association => true do
    describe "analyst" do
      it_behaves_like "required belongs_to", :analyst_assignment, :analyst
      it_behaves_like "immutable belongs_to", :analyst_assignment, :analyst
      it_behaves_like "deletable belongs_to", :analyst_assignment, :analyst
    end
  
    describe "analyst_role" do
      it_behaves_like "required belongs_to", :analyst_assignment, :analyst_role
      it_behaves_like "immutable belongs_to", :analyst_assignment, :analyst_role
      it_behaves_like "deletable belongs_to", :analyst_assignment, :analyst_role
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
      let(:analyst)      { FactoryGirl.create(:analyst) }
      let(:analyst_role) { FactoryGirl.create(:analyst_role) }
      
      it "creates analyst_assignments" do
        analyst.analyst_roles << analyst_role
        assignments = AnalystAssignment.where(:analyst => analyst, :analyst_role => analyst_role)
        assignments.should_not be_nil
      end
    end
  end
end