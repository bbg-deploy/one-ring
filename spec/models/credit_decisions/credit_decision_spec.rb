require 'spec_helper'

describe CreditDecision do
  # Model & Factory Validation
  #----------------------------------------------------------------------------
  describe "factory validation", :factory_validation => true do
    specify { CreditDecision.new.should be_an_instance_of(CreditDecision) }

    it_behaves_like "valid record", :credit_decision
    it_behaves_like "valid record", :approved_credit_decision
    it_behaves_like "valid record", :denied_credit_decision
    
    describe "approved_credit_decision factory" do
      it "is approved" do
        credit_decision = FactoryGirl.create(:approved_credit_decision)
        credit_decision.approved?.should be_true
      end
    end

    describe "denied_credit_decision factory" do
      it "is denied" do
        credit_decision = FactoryGirl.create(:denied_credit_decision)
        credit_decision.denied?.should be_true        
      end
    end
  end

  # Associations
  #----------------------------------------------------------------------------
  describe "associations", :associations => true do
    describe "lease_application" do
      it_behaves_like "required belongs_to", :credit_decision, :lease_application
      it_behaves_like "immutable belongs_to", :credit_decision, :lease_application
      it_behaves_like "deletable belongs_to", :credit_decision, :lease_application
    end
  end

  # Attributes
  #----------------------------------------------------------------------------
  describe "attributes", :attributes => true do
  end

  # State Machine
  #----------------------------------------------------------------------------
  describe "state_machine", :state_machine => true do
    describe "initial conditions" do
      it "defaults to undecisioned" do
        model = FactoryGirl.create(:credit_decision)
        model.undecisioned?.should be_true
      end
    end

    describe "events", :events => true do
      describe "decision" do
        context "with high report scores" do
        end

        context "with low report scores" do
        end
      end
    end
  end

  # Behavior
  #----------------------------------------------------------------------------
  describe "behavior", :behavior => true do
  end
end