require 'spec_helper'

describe Agent, :agent => true do
  # Model & Factory Validation
  #----------------------------------------------------------------------------
  describe "factory validation", :factory_validation => true do
    specify { Agent.new.should be_an_instance_of(Agent) }
    specify { expect { FactoryGirl.create(:agent) }.to_not raise_error }
  
    let(:agent) { FactoryGirl.create(:agent) }
    specify { agent.should be_valid }
    specify { agent.agent_roles.should_not be_empty }
    it "should be listed in the agent_assignments table" do
      agent.reload
      AgentAssignment.where(:agent_id => agent.id).should_not be_empty
    end
  end
  
  # Associations
  #----------------------------------------------------------------------------
  describe "associations", :associations => true do
  end

  # Attributes
  #----------------------------------------------------------------------------
  describe "attributes", :attributes => true do
    # This performs the standard checks for usernames, emails, passwords, etc.
    it_behaves_like "devise attributes (employee)", :agent

    describe "first_name" do
      it_behaves_like "attr_accessible", :agent, :first_name,
        ["Chris", "Mark-Anthony", "tHomAS", "Chris Topher", "O'Connelly", "12Street"], #Valid values
        [nil, "!", "(Chris);"] #Invalid values
    end
  
    describe "middle_name" do
      it_behaves_like "attr_accessible", :agent, :middle_name,
        [nil, "Chris", "Mark-Anthony", "tHomAS", "Chris Topher", "O'Connelly", "12Street"], #Valid values
        ["!", "(Chris);"] #Invalid values
    end
  
    describe "last_name" do
      it_behaves_like "attr_accessible", :agent, :last_name,
        ["Chris", "Mark-Anthony", "tHomAS", "Chris Topher", "O'Connelly", "12Street"], #Valid values
        [nil, "!", "(Chris);"] #Invalid values
    end
  
    describe "date_of_birth" do
      it_behaves_like "attr_accessible", :agent, :date_of_birth,
        [21.years.ago, 43.years.ago], #Valid values
        [nil, 17.years.ago, 5.years.ago] #Invalid values
    end
  end
  
  # Behavior
  #----------------------------------------------------------------------------
  describe "behavior", :behavior => true do
    describe "authentication", :authentication => true do
      it_behaves_like "devise authenticatable", :agent do
        # Authentication Configuration
        let(:domain) { "credda.com" }
        let(:case_insensitive_keys) { [:email] }
        let(:strip_whitespace_keys) { [:email] }
        let(:authentication_keys) { [:login] }
      end
      
      it_behaves_like "devise recoverable", :agent do
        # Recoverable Configuration
        let(:reset_password_keys) { [:email] }
        let(:reset_password_within) { 6.hours }
      end
  
      it_behaves_like "devise lockable", :agent do
        # Lockable Configuration
        let(:unlock_keys) { [:email] }
        let(:unlock_strategy) { :both }
        let(:maximum_attempts) { 10 }
        let(:unlock_in) { 1.hour }
      end
  
      it_behaves_like "devise rememberable", :agent do
        # Rememberable Configuration
        let(:remember_for) { 2.weeks }
      end
  
      it_behaves_like "devise timeoutable", :agent do
        # Timeoutable Configuration
        let(:timeout_in) { 30.minutes }
      end
  
      it_behaves_like "devise confirmable", :agent do
        # Confirmable Configuration
        let(:reconfirmable) { true }
        let(:confirmation_keys) { [:email] }
      end
    end
  end
end