require 'spec_helper'

describe PaymentProfile do
  # Model & Factory Validation
  #----------------------------------------------------------------------------
  describe "factory validation", :factory_validation => true do
    specify { PaymentProfile.new.should be_an_instance_of(PaymentProfile) }

    describe "payment_profile factory" do
      it_behaves_like "valid record", :payment_profile
    end

    describe "invalid_payment_profile factory" do
      it_behaves_like "invalid record", :invalid_payment_profile
    end

    describe "credit_card_payment_profile factory" do
      it_behaves_like "valid record", :credit_card_payment_profile
    end

    describe "bank_account_payment_profile factory" do
      it_behaves_like "valid record", :bank_account_payment_profile
    end

    describe "invalid_credit_card_payment_profile factory" do
      it_behaves_like "invalid record", :invalid_credit_card_payment_profile
    end

    describe "payment_profile_credit_card_attributes_hash" do
      it "creates new payment_profile when passed to PaymentProfile" do
        attributes = FactoryGirl.build(:payment_profile_credit_card_attributes_hash)
        payment_profile = PaymentProfile.create!(attributes)
        payment_profile.should be_valid
      end
    end

    describe "payment_profile_bank_account_attributes_hash" do
      it "creates new payment_profile when passed to PaymentProfile" do
        attributes = FactoryGirl.build(:payment_profile_bank_account_attributes_hash)
        payment_profile = PaymentProfile.create!(attributes)
        payment_profile.should be_valid
      end
    end
  end
 
  # Associations
  #----------------------------------------------------------------------------
  describe "associations", :associations => true do
    describe "customer" do
      it_behaves_like "immutable belongs_to", :payment_profile, :customer
      it_behaves_like "deletable belongs_to", :payment_profile, :customer
    end
    
    describe "payments" do
      #TODO: Test this.
      # Not Deleted on Destroy
    end
    
    describe "billing_address" do
      describe "validates nested attributes" do
        specify { expect { FactoryGirl.create(:payment_profile, billing_address_factory: :invalid_address) }.to raise_error }
      end
  
      describe "required association" do
        it "saves with billing_address" do
          expect{ customer = FactoryGirl.create(:payment_profile) }.to_not raise_error
        end

        it "raises error without billing_address" do
          expect{ customer = FactoryGirl.create(:payment_profile, with_billing_address: false) }.to raise_error
        end
      end
  
      describe "dependent destroy", :dependent_destroy => true do
        let(:payment_profile) { FactoryGirl.create(:payment_profile) }
        it_behaves_like "dependent destroy", :payment_profile, :billing_address
      end
    end

    describe "credit_card" do
      context "with payment_type == credit_card" do
        it "requires a credit card" do
          expect{ FactoryGirl.create(:payment_profile, :payment_type => "credit_card", with_credit_card: false) }.to raise_error
        end
      end

      context "with payment_type == bank_account" do
        it "does not require a credit card" do
          expect{ FactoryGirl.create(:payment_profile, :payment_type => "bank_account", with_credit_card: false) }.to_not raise_error
        end
      end
    end

    describe "bank_account" do
      context "with payment_type == credit_card" do
        it "does not require a bank account" do
          expect{ FactoryGirl.create(:payment_profile, :payment_type => "credit_card", with_bank_account: false) }.to_not raise_error
        end
      end

      context "with payment_type == bank_account" do
        it "requires a bank account" do
          expect{ FactoryGirl.create(:payment_profile, :payment_type => "bank_account", with_bank_account: false) }.to raise_error
        end
      end
    end
  end

  # Attributes
  #----------------------------------------------------------------------------
  describe "attributes", :attributes => true do  
    describe "cim_customer_payment_profile_id" do
      it_behaves_like "immutable attribute", :payment_profile, :cim_customer_payment_profile_id,
        ["1013344", "123000"], #Valid values
        [] #Invalid values
    end

    describe "first_name" do
      it_behaves_like "attr_accessible", :payment_profile, :first_name,
        ["Bryce", "Mike", "Football"], #Valid values
        [nil] #Invalid values
    end

    describe "last_name" do
      it_behaves_like "attr_accessible", :payment_profile, :last_name,
        ["Senz", "Dugas", "NFL"], #Valid values
        [nil] #Invalid values
    end
  end

  # Behavior
  #----------------------------------------------------------------------------
  describe "behavior", :behavior => true do
    describe "name" do
      it "returns name" do
        payment_profile = FactoryGirl.build(:payment_profile, :first_name => "Bob", :last_name => "Loblaw")
        payment_profile.name.should eq("Bob Loblaw")
      end
    end
    
    describe "set_last_four_digits" do
      context "with bank_account" do
        let(:bank_account) { FactoryGirl.build(:bank_account, :account_number => "112233445566") }
        let(:payment_profile) { FactoryGirl.build(:payment_profile, :payment_type => "bank_account") }

        it "should set last_four_digits" do
          payment_profile.bank_account = bank_account
          payment_profile.save
          payment_profile.last_four_digits.should eq("5566")
        end
      end

      context "with credit_card" do
        let(:credit_card) { FactoryGirl.build(:credit_card, :credit_card_number => "4111111111111111") }
        let(:payment_profile) { FactoryGirl.build(:payment_profile, :payment_type => "credit_card")}

        it "should set last_four_digits" do
          payment_profile.credit_card = credit_card
          payment_profile.save
          payment_profile.last_four_digits.should eq("1111")
        end
      end
    end

    describe "set_cim_customer_payment_profile_id" do
      context "without cim_customer_payment_profile_id" do
        let(:payment_profile) { FactoryGirl.build(:payment_profile, :cim_customer_payment_profile_id => nil) }
        it "sets profile id" do
          payment_profile.cim_customer_payment_profile_id.should be_nil
          payment_profile.set_cim_customer_payment_profile_id("1234567")
          payment_profile.cim_customer_payment_profile_id.should eq("1234567")
        end
      end

      context "without cim_customer_payment_profile_id" do
        let(:payment_profile) { FactoryGirl.build(:payment_profile) }
        it "does not change profile id" do
          payment_profile.cim_customer_payment_profile_id.should_not be_nil
          payment_profile.set_cim_customer_payment_profile_id("1234567")
          payment_profile.cim_customer_payment_profile_id.should_not eq("1234567")
        end
      end
    end

    describe "authorize_net_payment_details" do
      context "with credit card" do
        let(:payment_profile) { FactoryGirl.create(:credit_card_payment_profile) }
        let(:payment_details) { payment_profile.authorize_net_payment_details }

        it "returns payment details Hash" do
          payment_details.is_a?(Hash).should be_true
        end

        it "contains an ActiveMerchant Credit Card" do
          payment_details[:credit_card].is_a?(ActiveMerchant::Billing::CreditCard).should be_true
        end
      end

      context "with bank account" do
        let(:payment_profile) { FactoryGirl.create(:bank_account_payment_profile) }
        let(:payment_details) { payment_profile.authorize_net_payment_details }

        it "returns payment details Hash" do
          payment_details.is_a?(Hash).should be_true
        end

        it "contains an Hash of bank account details" do
          payment_details[:bank_account].is_a?(Hash).should be_true
        end
      end
    end

    describe "authorize_net_billing_details" do
      let(:payment_profile) { FactoryGirl.create(:credit_card_payment_profile) }
      let(:billing_details) { payment_profile.authorize_net_billing_details }

      it "returns billing details Hash" do
        billing_details.is_a?(Hash).should be_true
      end
    end
  end
end