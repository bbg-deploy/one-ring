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
      it { should validate_presence_of(:first_name) }
    end

    describe "last_name" do
      it { should validate_presence_of(:last_name) }
    end

    describe "account_holder" do
      it { should allow_mass_assignment_of(:account_holder) }
      it { should validate_presence_of(:account_holder) }
      it { should allow_value("personal", "business").for(:account_holder) }
      it { should_not allow_value(nil, "checking").for(:account_holder) }
    end

    describe "account_holder" do
      it { should allow_mass_assignment_of(:account_type) }
      it { should validate_presence_of(:account_type) }
      it { should allow_value("checking", "savings").for(:account_type) }
      it { should_not allow_value("personal", "banking", nil).for(:account_type) }
    end

    describe "account_number" do
      it { should allow_mass_assignment_of(:account_number) }
      it { should validate_presence_of(:account_number) }
      it { should allow_value("12345678", "98765432").for(:account_number) }
      it { should_not allow_value("12", "banking", nil).for(:account_number) }
    end

    describe "routing_number" do
      it { should allow_mass_assignment_of(:routing_number) }
      it { should validate_presence_of(:routing_number) }
      it { should allow_value("272483633", "211770200").for(:routing_number) }
      it { should_not allow_value(nil).for(:routing_number) }
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