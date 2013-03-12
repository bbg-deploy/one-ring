require 'spec_helper'

describe CreditDecision do
  # Model & Factory Validation
  #----------------------------------------------------------------------------
  describe "factory validation", :factory_validation => true do
    specify { CreditDecision.new.should be_an_instance_of(CreditDecision) }

    describe "credit factory" do
      it_behaves_like "valid record", :credit_decision
    end

    describe "credit_decision_attributes_hash" do
      it "creates new CreditDecision" do
        attributes = FactoryGirl.build(:credit_decision_attributes_hash)
        credit_decision = CreditDecision.create(attributes)
        credit_decision.should be_valid
      end
    end
  end
  
  # Database
  #----------------------------------------------------------------------------
  describe "database", :database => true do
    it { should have_db_column(:application_id) }
    it { should have_db_column(:status) }
  end

  # Associations
  #----------------------------------------------------------------------------
  describe "associations", :associations => true do
    describe "application" do
      it { should belong_to(:application) }
      it { should validate_presence_of(:application) }
      # TODO: This is broken.  Fix it.
#      it_behaves_like "immutable belongs_to", :credit_decision, :application
    end
  end

  # Attributes
  #----------------------------------------------------------------------------
  describe "attributes", :attributes => true do
    describe "status" do
      it { should_not allow_mass_assignment_of(:status) }
      it { should allow_value("pending", "approved", "denied").for(:status) }
    end
  end

  # Public Methods
  #----------------------------------------------------------------------------
  describe "public_methods", :public_methods => true do
  end
end