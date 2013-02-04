require 'spec_helper'

describe AgentAssignment, :agent => true do
  # Model & Factory Validation
  #----------------------------------------------------------------------------
  describe "factory_validation", :factory_validation => true do
    specify { AgentAssignment.new.should be_an_instance_of(AgentAssignment) }
    specify { expect { FactoryGirl.create(:agent_assignment) }.to_not raise_error }
  
    let(:agent_assignment) { FactoryGirl.create(:agent_assignment) }
    specify { agent_assignment.should be_valid }
    specify { agent_assignment.agent.should_not be_nil }
    specify { agent_assignment.agent_role.should_not be_nil }
  end

  # Assocations
  #----------------------------------------------------------------------------
  describe "associations", :associations => true do
    describe "agent" do
      it_behaves_like "required belongs_to", :agent_assignment, :agent
      it_behaves_like "immutable belongs_to", :agent_assignment, :agent
      it_behaves_like "deletable belongs_to", :agent_assignment, :agent
    end
  
    describe "agent_role" do
      it_behaves_like "required belongs_to", :agent_assignment, :agent_role
      it_behaves_like "immutable belongs_to", :agent_assignment, :agent_role
      it_behaves_like "deletable belongs_to", :agent_assignment, :agent_role
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
      let(:agent)      { FactoryGirl.create(:agent) }
      let(:agent_role) { FactoryGirl.create(:agent_role) }
      
      it "creates agent_assignments" do
        agent.agent_roles << agent_role
        assignments = AgentAssignment.where(:agent => agent, :agent_role => agent_role)
        assignments.should_not be_nil
      end
    end
  end
end