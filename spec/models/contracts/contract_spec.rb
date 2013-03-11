require 'spec_helper'

describe Contract do
  # Model & Factory Validation
  #----------------------------------------------------------------------------
  describe "factory validation", :factory_validation => true do
    specify { Contract.new.should be_an_instance_of(Contract) }

    describe "contract factory" do
      it_behaves_like "valid record", :contract
    end

    describe "contract_attributes_hash" do
      it "creates new Contract" do
        attributes = FactoryGirl.build(:contract_attributes_hash)
        contract = Contract.create(attributes)
        contract.should be_valid
      end
    end
  end
  
  # Database
  #----------------------------------------------------------------------------
  describe "database", :database => true do
    it { should have_db_column(:customer_account_number) }
    it { should have_db_column(:application_number) }
    it { should have_db_index(:application_number) }
    it { should have_db_column(:contract_number) }
  end

  # Associations
  #----------------------------------------------------------------------------
  describe "associations", :associations => true do
    describe "ledger" do
      it { should have_one(:ledger) }
    end
  end

  # Attributes
  #----------------------------------------------------------------------------
  describe "attributes", :attributes => true do
    describe "customer_account_number" do
      it { should allow_mass_assignment_of(:customer_account_number) }
      it { should validate_presence_of(:customer_account_number) }
      it { should allow_value("Chris", "James", "CUS1020303").for(:customer_account_number) }
      it { should_not allow_value(nil).for(:customer_account_number) }
      #TODO: this isn't working
#      it_behaves_like "immutable attribute", :contract, :customer_account_number
    end

    describe "application_id" do
      it { should allow_mass_assignment_of(:application_number) }
      it { should validate_presence_of(:application_number) }
      it { should allow_value("Chris", "James", "CUS1020303").for(:application_number) }
      it { should_not allow_value(nil).for(:application_number) }
      #TODO: this isn't working
#      it_behaves_like "immutable attribute", :contract, :application_number
    end

    describe "contract_number" do
      it { should allow_mass_assignment_of(:contract_number) }
      it { should validate_presence_of(:contract_number) }
      it { should allow_value("Chris", "James", "CUS1020303").for(:contract_number) }
      it { should_not allow_value(nil).for(:contract_number) }
      #TODO: this isn't working
#      it_behaves_like "immutable attribute", :contract, :contract_number
    end
  end
  
  # State Machine
  #----------------------------------------------------------------------------
  describe "state_machine", :state_machine => true do
  end

  # Behavior
  #----------------------------------------------------------------------------
  describe "behavior", :behavior => true do
  end

  # Private Methods
  #----------------------------------------------------------------------------
  describe "private_methods", :private_methods => true do
  end
end