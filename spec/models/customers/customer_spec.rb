require 'spec_helper'

describe Customer do
  # Model & Factory Validation
  #----------------------------------------------------------------------------
  describe "factory validation", :factory_validation => true do
    specify { Customer.new.should be_an_instance_of(Customer) }
  
    describe "customer factory" do
      it_behaves_like "valid record", :customer

      it "should have a phone number" do
        customer = FactoryGirl.create(:customer)
        customer.phone_number.should_not be_nil
      end

      it "should have a mailing address" do
        customer = FactoryGirl.create(:customer)
        customer.mailing_address.should_not be_nil
      end
    end

    describe "invalid_customer factory" do
      it_behaves_like "invalid record", :invalid_customer
    end

    describe "customer_no_id factory" do
      it_behaves_like "valid record", :customer_no_id
    
      it "has no cim_customer_profile_id" do
        customer = FactoryGirl.build(:customer_no_id)
        customer.cim_customer_profile_id.should be_nil
      end
    end
    
    describe "customer_with_payment_profiles factory" do
      it_behaves_like "valid record", :customer_with_payment_profiles
    
      it "has payment_profiles" do
        customer = FactoryGirl.create(:customer_with_payment_profiles)
        customer.payment_profiles.should_not be_empty
      end      
    end
    
    describe "customer_attributes_hash" do
      it "creates new customer when passed to Customer" do
        attributes = FactoryGirl.build(:customer_attributes_hash)
        customer = Customer.create(attributes)
        customer.should be_valid
      end
    end
  end

  # Associations
  #----------------------------------------------------------------------------
  describe "associations", :associations => true do
    describe "mailing_address" do
      describe "validates nested attributes" do
        specify { expect { FactoryGirl.create(:customer, mailing_address_factory: :invalid_address) }.to raise_error }
      end
  
      describe "required association" do
        it "saves with mailing_address" do
          expect{ customer = FactoryGirl.create(:customer) }.to_not raise_error
        end

        it "raises error without mailing_address" do
          expect{ customer = FactoryGirl.create(:customer, with_mailing_address: false) }.to raise_error
        end
      end
  
      describe "dependent destroy", :dependent_destroy => true do
        let(:customer) { FactoryGirl.create(:customer) }
        it_behaves_like "dependent destroy", :customer, :mailing_address
      end
    end
      
    describe "phone number" do
      describe "validates nested attributes" do
        specify { expect { FactoryGirl.create(:customer, phone_number_factory: :invalid_phone_number) }.to raise_error }
      end
  
      describe "required association" do
        it "saves with phone_number" do
          expect{ customer = FactoryGirl.create(:customer) }.to_not raise_error
        end

        it "raises error without phone_number" do
          expect{ customer = FactoryGirl.create(:customer, with_phone_number: false) }.to raise_error
        end
      end
  
      describe "dependent destroy", :dependent_destroy => true do
        let(:customer) { FactoryGirl.create(:customer) }
        it_behaves_like "dependent destroy", :customer, :phone_number
      end
    end

    describe "payment_profiles" do
      describe "dependent destroy", :dependent_destroy => true do
        let(:customer) { FactoryGirl.create(:customer) }
        it_behaves_like "dependent destroy", :customer_with_payment_profiles, :payment_profiles
      end
    end
  end

  # Attributes
  #----------------------------------------------------------------------------
  describe "attributes", :attributes => true do
    # This performs the standard checks for usernames, emails, passwords, etc.
    it_behaves_like "devise attributes (non-employee)", :customer
      
    describe "first_name" do
      it_behaves_like "attr_accessible", :customer, :first_name,
        ["Chris", "Mark-Anthony", "tHomAS", "Chris Topher", "O'Connelly", "12Street"], #Valid values
        [nil, "!", "(Chris);"] #Invalid values
    end
  
    describe "middle_name" do
      it_behaves_like "attr_accessible", :customer, :middle_name,
        [nil, "Chris", "Mark-Anthony", "tHomAS", "Chris Topher", "O'Connelly", "12Street"], #Valid values
        ["!", "(Chris);"] #Invalid values
    end
  
    describe "last_name" do
      it_behaves_like "attr_accessible", :customer, :last_name,
        ["Chris", "Mark-Anthony", "tHomAS", "Chris Topher", "O'Connelly", "12Street"], #Valid values
        [nil, "!", "(Chris);"] #Invalid values
    end
  
    describe "date_of_birth" do
      it_behaves_like "attr_accessible", :customer, :date_of_birth,
        [21.years.ago, 43.years.ago], #Valid values
        [nil, 17.years.ago, 5.years.ago] #Invalid values
    end
  
    describe "SSN" do
      it_behaves_like "attr_accessible", :customer, :social_security_number,
        ["733111121", "733-11-1123"], #Valid values
        [nil, "73311112", "7331111212", "000-11-1111", "733-00-1111", "733-11-0000", "987-65-4320", "666-34-1234"] #Invalid values
    end    
  end
  
  # Behavior
  #----------------------------------------------------------------------------
  describe "behavior", :behavior => true do
  end

  # Devise
  #----------------------------------------------------------------------------
  describe "devise", :devise => true do
    it_behaves_like "devise authenticatable", :customer do
      # Authentication Configuration
      let(:domain) { "notcredda.com" }
      let(:case_insensitive_keys) { [:email] }
      let(:strip_whitespace_keys) { [:email] }
      let(:authentication_keys) { [:login] }
    end
    
    it_behaves_like "devise recoverable", :customer do
      # Recoverable Configuration
      let(:reset_password_keys) { [:email] }
      let(:reset_password_within) { 6.hours }
    end

    it_behaves_like "devise lockable", :customer do
      # Lockable Configuration
      let(:unlock_keys) { [:email] }
      let(:unlock_strategy) { :both }
      let(:maximum_attempts) { 10 }
      let(:unlock_in) { 1.hour }
    end

    it_behaves_like "devise rememberable", :customer do
      # Rememberable Configuration
      let(:remember_for) { 2.weeks }
    end

    it_behaves_like "devise timeoutable", :customer do
      # Timeoutable Configuration
      let(:timeout_in) { 30.minutes }
    end

    it_behaves_like "devise confirmable", :customer do
      # Confirmable Configuration
      let(:reconfirmable) { true }
      let(:confirmation_keys) { [:email] }
    end
  end
end