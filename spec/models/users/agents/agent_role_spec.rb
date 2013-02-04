require 'spec_helper'

describe AgentRole, :agent => true do
  # Model & Factory Validation
  #----------------------------------------------------------------------------
  describe "factory validation", :factory_validation => true do
    specify { AgentRole.new.should be_an_instance_of(AgentRole) }
    specify { expect { FactoryGirl.create(:agent_role) }.to_not raise_error }
  end
  
  # Associations
  #----------------------------------------------------------------------------
  describe "assocations", :associations => true do
    describe "admins" do
      it "doesn't require admin presence" do
        agent_role = FactoryGirl.create(:agent_role, :number_of_agents => 0)
        agent_role.should be_valid
        agent_role.agents.count.should eq(0)
      end
      
      it "successfully associates admins" do
        agent_role = FactoryGirl.create(:agent_role, :number_of_agents => 4)
        agent_role.should be_valid
        agent_role.agents.count.should eq(4)
      end
    end    
  end

  # Attributes
  #----------------------------------------------------------------------------
  describe "attributes", :attributes => true do
    describe "name" do
      it_behaves_like "attr_accessible", :agent_role, :name,
        ["role", "role_one", "more_descriptive_role"], #Valid values
        [nil, "!", "role2", "Role_Two"] #Invalid values
    end
    
    describe "description" do
      it_behaves_like "attr_accessible", :agent_role, :description,
        ["demo description", "Lorem Ipsum!"], #Valid values
        [nil] #Invalid values
    end
  
    describe "permanent" do
      it_behaves_like "attr_accessible", :agent_role, :permanent,
        [true, false], #Valid values
        [nil] #Invalid values
    end  
  end
  
  # Behavior
  #----------------------------------------------------------------------------
  describe "behavior", :behavior => true do
    describe "to_s" do
      it "returns name as to_s" do
        agent_role = FactoryGirl.create(:agent_role, :name => "test_name")
        agent_role.to_s.should eq("test_name")
      end
    end
  end
end
