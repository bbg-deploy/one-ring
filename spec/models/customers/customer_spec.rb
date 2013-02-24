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

  # Database
  #----------------------------------------------------------------------------
  describe "database", :database => true do
    # Account Information
    it { should have_db_column(:account_number) }
    it { should have_db_index(:account_number) }
    it { should have_db_column(:username) }
    it { should have_db_index(:username) }
    it { should have_db_column(:email) }
    it { should have_db_index(:email) }
    it { should have_db_column(:encrypted_password) }

    # Personal Information
    it { should have_db_column(:first_name) }
    it { should have_db_column(:middle_name) }
    it { should have_db_column(:last_name) }
    it { should have_db_column(:date_of_birth) }
    it { should have_db_column(:social_security_number) }

    # Recoverable
    it { should have_db_column(:reset_password_token) }
    it { should have_db_column(:reset_password_sent_at) }

    # Rememberable
    it { should have_db_column(:remember_created_at) }

    # Trackable
    it { should have_db_column(:sign_in_count) }
    it { should have_db_column(:current_sign_in_at) }
    it { should have_db_column(:last_sign_in_at) }
    it { should have_db_column(:current_sign_in_ip) }
    it { should have_db_column(:last_sign_in_ip) }

    # Confirmable
    it { should have_db_column(:confirmation_token) }
    it { should have_db_column(:confirmed_at) }
    it { should have_db_column(:confirmation_sent_at) }
    it { should have_db_column(:unconfirmed_email) }

    # Lockable
    it { should have_db_column(:failed_attempts) }
    it { should have_db_column(:unlock_token) }
    it { should have_db_column(:locked_at) }

    # Token authenticatable
    it { should have_db_column(:authentication_token) }

    # CIM Customer Profile ID
    it { should have_db_column(:cim_customer_profile_id) }
  end

  # Associations
  #----------------------------------------------------------------------------
  describe "associations", :associations => true do
    describe "mailing_address" do
      it { should have_one(:mailing_address) }
      it { should accept_nested_attributes_for(:mailing_address) }

      describe "validates nested attributes" do
        #TODO: Use Hash class for this test instead
        specify { expect { FactoryGirl.create(:customer, mailing_address_factory: :invalid_address) }.to raise_error }
      end
  
      describe "required association" do
        it { should validate_presence_of(:mailing_address) }
      end
  
      describe "dependent destroy", :dependent_destroy => true do
        let(:customer) { FactoryGirl.create(:customer) }
        it_behaves_like "dependent destroy", :customer, :mailing_address
      end
    end
      
    describe "phone number" do
      it { should have_one(:phone_number) }

      describe "validates nested attributes" do
        #TODO: Use Hash class for this test instead
        specify { expect { FactoryGirl.create(:customer, phone_number_factory: :invalid_phone_number) }.to raise_error }
      end
  
      describe "required association" do
        it { should validate_presence_of(:phone_number) }
      end
  
      describe "dependent destroy", :dependent_destroy => true do
        let(:customer) { FactoryGirl.create(:customer) }
        it_behaves_like "dependent destroy", :customer, :phone_number
      end
    end

    describe "payment_profiles" do
      it { should have_many(:payment_profiles) }

      describe "dependent destroy", :dependent_destroy => true do
        let(:customer) { FactoryGirl.create(:customer) }
        it_behaves_like "dependent destroy", :customer_with_payment_profiles, :payment_profiles
      end
    end
  end

  # Attributes
  #----------------------------------------------------------------------------
  describe "attributes", :attributes => true do
    before(:each) do
      attributes = FactoryGirl.build(:customer_attributes_hash)
      customer = Customer.create!(attributes) 
    end

    describe "account_number" do
      it { should validate_uniqueness_of(:account_number) }

      it "should not be nil" do
        customer = FactoryGirl.create(:customer)
        customer.account_number.should_not be_nil
      end

      it "should start with 'UCU'" do
        customer = FactoryGirl.create(:customer)
        customer.account_number.start_with?('UCU').should be_true
      end
    end

    describe "username" do
      it { should allow_mass_assignment_of(:username) }
      it { should validate_presence_of(:username) }
      it { should validate_uniqueness_of(:username) }
      it { should allow_value("Chris", "James", "tHomAS", "isexactlytwentychars").for(:username) }
      it { should_not allow_value(nil, "!", "cat", "Chris Topher", "admin", "demo", "12Street", "ithastoomanycharacters").for(:username) }

      it "downcases username" do
        customer = FactoryGirl.create(:customer, :username => "BiLLy")
        customer.username.should eq("billy")
      end

      it "strips leading whitespace" do
        customer = FactoryGirl.create(:customer, :username => " whitespace")
        customer.username.should eq("whitespace")
      end

      it "strips trailing whitespace" do
        customer = FactoryGirl.create(:customer, :username => "whitespace ")
        customer.username.should eq("whitespace")
      end

      it "does not allow whitespace in the middle" do
        customer = FactoryGirl.build(:customer, :username => "white space")
        customer.should_not be_valid
      end
    end

    describe "email" do
      it { should allow_mass_assignment_of(:email) }
      it { should validate_presence_of(:email) }
      it { should validate_confirmation_of(:email) }
      it { should validate_uniqueness_of(:email) }
      it { should allow_value("valid@notcredda.com").for(:email) }
      it { should_not allow_value(nil, "valid@credda.com", "valid.notcredda.com", "@notcredda.com").for(:email) }

      it "downcases email" do
        customer = FactoryGirl.create(:customer, :email => "TEST@notcredda.com")
        customer.email.should eq("test@notcredda.com")
      end

      it "strips leading whitespace" do
        customer = FactoryGirl.create(:customer, :email => " white@notcredda.com")
        customer.email.should eq("white@notcredda.com")
      end
      
      it "strips trailing whitespace" do
        customer = FactoryGirl.create(:customer, :email => "white@notcredda.com ")
        customer.email.should eq("white@notcredda.com")
      end

      it "strips whitespace in the middle" do
        customer = FactoryGirl.create(:customer, :email => "white @ notcredda.com")
        customer.email.should eq("white@notcredda.com")
      end
    end

    describe "password" do
      it { should allow_mass_assignment_of(:password) }
      it { should validate_presence_of(:password) }
      it { should validate_confirmation_of(:password) }
      it { should allow_value("S3curePass", "ValidPassW0rd").for(:password) }
      it { should_not allow_value(nil, "!", "123", "abc").for(:password) }
    end

    describe "first_name" do
      it { should allow_mass_assignment_of(:first_name) }
      it { should validate_presence_of(:first_name) }
      it { should allow_value("Chris", "Mark-Anthony", "tHomAS", "Chris Topher", "O'Connelly", "12Street").for(:first_name) }
      it { should_not allow_value(nil, "!", "(Chris);").for(:first_name) }
    end
  
    describe "middle_name" do
      it { should allow_mass_assignment_of(:middle_name) }
      it { should_not validate_presence_of(:middle_name) }
      it { should allow_value("Chris", "Mark-Anthony", "tHomAS", "Chris Topher", "O'Connelly", "12Street").for(:middle_name) }
      it { should_not allow_value(nil, "!", "(Chris);").for(:middle_name) }
    end

    describe "last_name" do
      it { should allow_mass_assignment_of(:last_name) }
      it { should validate_presence_of(:last_name) }
      it { should allow_value("Chris", "Mark-Anthony", "tHomAS", "Chris Topher", "O'Connelly", "12Street").for(:last_name) }
      it { should_not allow_value(nil, "!", "(Chris);").for(:last_name) }
    end
  
    describe "date_of_birth" do
      it { should allow_mass_assignment_of(:date_of_birth) }
      it { should validate_presence_of(:date_of_birth) }
      it { should allow_value(21.years.ago, 43.years.ago).for(:date_of_birth) }
      it { should_not allow_value(nil, 17.years.ago, 5.years.ago).for(:date_of_birth) }
    end
  
    describe "SSN" do
      it { should allow_mass_assignment_of(:social_security_number) }
      it { should validate_presence_of(:social_security_number) }
      it { should validate_uniqueness_of(:social_security_number) }
      it { should allow_value("733111121", "733-11-1123").for(:social_security_number) }
      it { should_not allow_value(nil, "73311112", "7331111212", "733-00-1111", "733-11-0000", "987-65-4320", "666-34-1234").for(:social_security_number) }
    end

    describe "terms agreement" do
      it { should allow_mass_assignment_of(:terms_agreement) }
      it { should validate_acceptance_of(:terms_agreement) }
      it { should allow_value("1").for(:terms_agreement) }
      it { should_not allow_value("0").for(:terms_agreement) }
    end
  end
  
  # Public Methods
  #----------------------------------------------------------------------------
  describe "public methods", :public_methods => true do
    describe "cancel_account!" do
      let(:customer) { FactoryGirl.create(:customer) }
      
      it "should set cancelled account to current time" do
        customer.cancelled_at.should be_nil
        customer.cancel_account!
        customer.cancelled_at.should be_within(1.minute).of(DateTime.now)
      end
    end

    describe "cancelled?" do
      let(:customer) { FactoryGirl.create(:customer) }
      
      context "without cancellation" do
        it "should be false" do
          customer.cancelled?.should be_false
        end
      end

      context "without cancellation" do
        it "should be true" do
          customer.cancel_account!
          customer.cancelled?.should be_true
        end
      end
    end

    describe "active_for_authentication?" do
      let(:customer) { FactoryGirl.create(:customer) }

      context "as unconfirmed" do
        it "should be active for authentication" do
          customer.active_for_authentication?.should be_false
        end
      end

      context "as confirmed" do
        it "should be active for authentication" do
          customer.confirm!
          customer.active_for_authentication?.should be_true
        end
      end

      context "as locked" do
        it "should not be active for authentication" do
          customer.confirm!
          customer.lock_access!
          customer.active_for_authentication?.should be_false
        end
      end

      context "as cancelled" do
        it "should not be active for authentication" do
          customer.confirm!
          customer.cancel_account!
          customer.active_for_authentication?.should be_false
        end
      end
    end
  end

  # Devise
  #----------------------------------------------------------------------------
  describe "devise", :devise => true do
    describe "database authenticatable" do
      it_behaves_like "devise authenticatable", :customer do
        # Authentication Configuration
        let(:domain) { "notcredda.com" }
        let(:case_insensitive_keys) { [:email] }
        let(:strip_whitespace_keys) { [:email] }
        let(:authentication_keys) { [:login] }
      end
    end
    
    describe "recoverable" do
      it_behaves_like "devise recoverable", :customer do
        # Recoverable Configuration
        let(:reset_password_keys) { [:email] }
        let(:reset_password_within) { 6.hours }
      end
    end

    describe "lockable" do
      it_behaves_like "devise lockable", :customer do
        # Lockable Configuration
        let(:unlock_keys) { [:email] }
        let(:unlock_strategy) { :both }
        let(:maximum_attempts) { 5 }
        let(:unlock_in) { 1.hour }
      end
    end

    describe "rememberable" do
      it_behaves_like "devise rememberable", :customer do
        # Rememberable Configuration
        let(:remember_for) { 2.weeks }
      end
    end

    describe "timeoutable" do
      it_behaves_like "devise timeoutable", :customer do
        # Timeoutable Configuration
        let(:timeout_in) { 30.minutes }
      end
    end

    describe "confirmable" do  
      it_behaves_like "devise confirmable", :customer do
        # Confirmable Configuration
        let(:reconfirmable) { true }
        let(:confirmation_keys) { [:email] }
      end
    end
  end
end