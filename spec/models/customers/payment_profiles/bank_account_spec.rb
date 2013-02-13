require 'spec_helper'

describe BankAccount do
  # Model & Factory Validation
  #----------------------------------------------------------------------------
  describe "factory validation", :factory_validation => true do
    specify { BankAccount.new.should be_an_instance_of(BankAccount) }

    describe "bank_account factory" do
      it_behaves_like "valid record", :bank_account
    end
    
    describe "invalid_bank_account factory" do
      it_behaves_like "invalid record", :invalid_bank_account
    end

    describe "bank_account_attributes_hash" do
      it "creates new bank_account when passed to BankAccount" do
        attributes = FactoryGirl.build(:bank_account_attributes_hash)
        bank_account = BankAccount.create!(attributes)
        bank_account.should be_valid
      end
    end
  end
 
  # Associations
  #----------------------------------------------------------------------------
  describe "associations", :associations => true do
    describe "payment_profile" do
      it_behaves_like "required belongs_to", :bank_account, :payment_profile
    end
  end

  # Attributes
  #----------------------------------------------------------------------------
  describe "attributes", :attributes => true do  
    describe "first_name" do
      it_behaves_like "attr_accessible", :bank_account, :first_name,
        ["Bryce", "Chris"], #Valid values
        [nil] #Invalid values
    end

    describe "last_name" do
      it_behaves_like "attr_accessible", :bank_account, :first_name,
        ["Senz", "Dugas"], #Valid values
        [nil] #Invalid values
    end

    describe "account_holder" do
      it_behaves_like "attr_accessible", :bank_account, :account_holder,
        ["personal", "business"], #Valid values
        ["checking", nil] #Invalid values        
    end

    describe "account_holder" do
      it_behaves_like "attr_accessible", :bank_account, :account_type,
        ["checking", "savings"], #Valid values
        ["personal", "banking", nil] #Invalid values
    end

    describe "account_number" do
      it_behaves_like "attr_accessible", :bank_account, :account_number,
        ["12345678", "98765432"], #Valid values
        ["12", nil] #Invalid values
    end

    describe "routing_number" do
      it_behaves_like "attr_accessible", :bank_account, :routing_number,
        ["272483633", "211770200"], #Valid values
        [nil] #Invalid values
    end
  end

  # Behavior
  #----------------------------------------------------------------------------
  describe "behavior", :behavior => true do
    describe "echeck_format" do
      let(:bank_account) { FactoryGirl.create(:bank_account) }

      it "returns Authorize.net card" do
        bank = bank_account.echeck_format
        bank.is_a?(ActiveMerchant::Billing::Check).should be_true
      end
    end

    describe "authorize_net_format" do
      let(:bank_account) { FactoryGirl.create(:bank_account) }

      it "returns Hash of attributes" do
        bank = bank_account.authorize_net_format
        bank.is_a?(Hash).should be_true
      end
    end
  end
end