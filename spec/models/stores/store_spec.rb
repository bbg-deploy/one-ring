require 'spec_helper'

describe Store, :store => true do
  # Model & Factory Validation
  #----------------------------------------------------------------------------
  describe "factory validation", :factory_validation => true do
    specify { Store.new.should be_an_instance_of(Store) }

    describe "store factory" do
      it_behaves_like "valid record", :store
      
      it "should have phone numbers" do
        store = FactoryGirl.create(:store)
        store.phone_numbers.should_not be_empty
      end

      it "should have addresses" do
        store = FactoryGirl.create(:store)
        store.addresses.should_not be_empty
      end
    end

    describe "invalid_store factory" do
      it_behaves_like "invalid record", :invalid_store
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
    it { should have_db_column(:name) }
    it { should have_db_column(:employer_identification_number) }

    # Recoverable
    it { should have_db_column(:reset_password_token) }
    it { should have_db_index(:reset_password_token) }
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
    it { should have_db_index(:confirmation_token) }
    it { should have_db_column(:confirmed_at) }
    it { should have_db_column(:confirmation_sent_at) }
    it { should have_db_column(:unconfirmed_email) }

    # Lockable
    it { should have_db_column(:failed_attempts) }
    it { should have_db_column(:unlock_token) }
    it { should have_db_column(:locked_at) }

    # Token authenticatable
    it { should have_db_column(:authentication_token) }
  end

  # Associations
  #----------------------------------------------------------------------------
  describe "associations", :associations => true do    
    describe "addresses" do
      describe "validates nested attributes" do
        specify { expect { FactoryGirl.create(:store, :address_factory => :invalid_address) }.to raise_error }
      end
  
      describe "required association" do
        it_behaves_like "required association" do
          let(:factory) { :store }
          let(:nested_attribute_modifier) { :number_of_addresses }
        end
      end

      describe "dependent destroy", :dependent_destroy => true do
        before(:each) { Store.any_instance.stub(:deletable?).and_return(true) }
        it_behaves_like "dependent destroy", :store, :addresses
      end
    end
  
    describe "phone_numbers", :failing => true do
      describe "validates nested attributes" do
        specify { expect { FactoryGirl.create(:store, :phone_number_factory => :invalid_phone_number) }.to raise_error }
      end
  
      describe "required association" do
        it_behaves_like "required association" do
          let(:factory) { :store }
          let(:nested_attribute_modifier) { :number_of_phone_numbers }
        end
      end
  
      describe "dependent destroy", :dependent_destroy => true do
        before(:each) { Store.any_instance.stub(:deletable?).and_return(true) }
        it_behaves_like "dependent destroy", :store, :phone_numbers
      end
    end
  end
  
  # Attributes
  #----------------------------------------------------------------------------
  describe "attributes", :attributes => true do
    before(:each) do
      attributes = FactoryGirl.build(:store_attributes_hash)
      store = Store.create!(attributes) 
    end

    describe "account_number" do
      it { should validate_uniqueness_of(:account_number) }

      it "should not be nil" do
        store = FactoryGirl.create(:store)
        store.account_number.should_not be_nil
      end

      it "should start with 'UST'" do
        store = FactoryGirl.create(:store)
        store.account_number.start_with?('UST').should be_true
      end
    end

    describe "username" do
      it { should allow_mass_assignment_of(:username) }
      it { should validate_presence_of(:username) }
      it { should validate_uniqueness_of(:username) }
      it { should allow_value("Chris", "James", "tHomAS", "isexactlytwentychars").for(:username) }
      it { should_not allow_value(nil, "!", "cat", "Chris Topher", "admin", "demo", "12Street", "ithastoomanycharacters").for(:username) }

      it "downcases username" do
        store = FactoryGirl.create(:store, :username => "ACmeCo")
        store.username.should eq("acmeco")
      end

      it "strips leading whitespace" do
        store = FactoryGirl.create(:store, :username => " whitespace")
        store.username.should eq("whitespace")
      end

      it "strips trailing whitespace" do
        store = FactoryGirl.create(:store, :username => "whitespace ")
        store.username.should eq("whitespace")
      end

      it "does not allow whitespace in the middle" do
        store = FactoryGirl.build(:store, :username => "white space")
        store.should_not be_valid
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
        store = FactoryGirl.create(:store, :email => "TEST@notcredda.com")
        store.email.should eq("test@notcredda.com")
      end

      it "strips leading whitespace" do
        store = FactoryGirl.create(:store, :email => " white@notcredda.com")
        store.email.should eq("white@notcredda.com")
      end
      
      it "strips trailing whitespace" do
        store = FactoryGirl.create(:store, :email => "white@notcredda.com ")
        store.email.should eq("white@notcredda.com")
      end

      it "strips whitespace in the middle" do
        store = FactoryGirl.create(:store, :email => "white @ notcredda.com")
        store.email.should eq("white@notcredda.com")
      end
    end

    describe "password" do
      it { should allow_mass_assignment_of(:password) }
      it { should validate_presence_of(:password) }
      it { should validate_confirmation_of(:password) }
      it { should allow_value("S3curePass", "ValidPassW0rd").for(:password) }
      it { should_not allow_value(nil, "!", "123", "abc").for(:password) }
    end

    describe "name" do
      it { should allow_mass_assignment_of(:name) }
      it { should validate_presence_of(:name) }
      it { should allow_value("Credda", "Google", "123Web Services").for(:name) }
      it { should_not allow_value(nil).for(:name) }
    end
    
    describe "EIN" do
      it { should allow_mass_assignment_of(:employer_identification_number) }
      it { should validate_presence_of(:employer_identification_number) }
      it { should validate_uniqueness_of(:employer_identification_number) }
      it { should allow_value("107331121", "10-7331121").for(:employer_identification_number) }
      it { should_not allow_value(nil, "73311112", "7331111222", "00-1111111", "10-0000000", "07-7654320").for(:employer_identification_number) }
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
    describe "name" do
      it "returns store name" do
        store = FactoryGirl.create(:store, :name => "Widget Company")
        store.name.should eq("Widget Company")
      end
    end
    
    describe "inactive_message" do
      context "as unapproved" do
        it "returns unconfirmed" do
          store = FactoryGirl.create(:store)
          store.inactive_message.should eq(:not_approved)
        end
      end

      context "as unconfirmed" do
        it "returns unconfirmed" do
          store = FactoryGirl.create(:approved_store)
          store.inactive_message.should eq(:unconfirmed)
        end
      end

      context "as cancelled" do
        it "returns correct message" do
          store = FactoryGirl.create(:cancelled_store)
          store.inactive_message.should eq(:cancelled)
        end
      end
    end

    describe "applications" do
      context "with no applications" do
        it "returns empty array" do
          store = FactoryGirl.create(:confirmed_store)
          store.applications.should eq([])
        end
      end

      context "with applications" do
        it "returns array of customer's applications" do
          store = FactoryGirl.create(:confirmed_store)
          application_1 = FactoryGirl.create(:unclaimed_application, :store_account_number => store.account_number)
          application_2 = FactoryGirl.create(:unclaimed_application, :store_account_number => store.account_number)
          application_3 = FactoryGirl.create(:unclaimed_application)
          store.applications.should eq([application_1, application_2])
        end
      end
    end

    describe "cancelable?" do
      it "should be true" do
        store = FactoryGirl.create(:store)
        store.cancellable?.should be_true
      end
    end
    
    describe "cancel_account!" do
      let(:store) { FactoryGirl.create(:store) }
      
      it "should set cancelled account to current time" do
        store.cancelled_at.should be_nil
        store.cancel_account!
        store.cancelled_at.should be_within(1.minute).of(DateTime.now)
      end
    end

    describe "cancelled?" do
      let(:store) { FactoryGirl.create(:store) }
      
      context "without cancellation" do
        it "should be false" do
          store.cancelled?.should be_false
        end
      end

      context "without cancellation" do
        it "should be true" do
          store.cancel_account!
          store.cancelled?.should be_true
        end
      end
    end

    describe "deletable?" do
      it "should be false" do
        store = FactoryGirl.create(:store)
        store.deletable?.should be_false
      end
    end

    describe "destroy" do
      it "should return false" do
        store = FactoryGirl.create(:store)
        store.destroy.should be_false
      end

      it "should persist the Employee" do
        store = FactoryGirl.create(:store)
        store.destroy
        store.reload
        store.should be_valid
      end      
    end

    describe "active_for_authentication?" do
      let(:store) { FactoryGirl.create(:store) }

      context "as unapproved" do
        it "should be active for authentication" do
          store.active_for_authentication?.should be_false
        end
      end

      context "as approved" do
        it "should not be active for authentication" do
          store.approve_account!
          store.active_for_authentication?.should be_false
        end
      end

      context "as approved and confirmed" do
        it "should not be active for authentication" do
          store.approve_account!
          store.confirm!
          store.active_for_authentication?.should be_true
        end
      end

      context "as locked" do
        it "should not be active for authentication" do
          store.approve_account!
          store.confirm!
          store.lock_access!
          store.active_for_authentication?.should be_false
        end
      end

      context "as cancelled" do
        it "should not be active for authentication" do
          store.approve_account!
          store.confirm!
          store.cancel_account!
          store.active_for_authentication?.should be_false
        end
      end
    end
  end

  # Devise
  #----------------------------------------------------------------------------
  describe "devise", :devise => true do
    describe "database authenticatable" do
      it_behaves_like "devise authenticatable", :confirmed_store do
        # Authentication Configuration
        let(:case_insensitive_keys) { [:email] }
        let(:strip_whitespace_keys) { [:email] }
        let(:authentication_keys) { [:login] }
      end
    end
      
    describe "recoverable" do
      it_behaves_like "devise recoverable", :confirmed_store do
        # Recoverable Configuration
        let(:reset_password_keys) { [:email] }
        let(:reset_password_within) { 6.hours }
      end
    end
  
    describe "lockable" do
      it_behaves_like "devise lockable", :confirmed_store do
        # Lockable Configuration
        let(:unlock_keys) { [:email] }
        let(:unlock_strategy) { :both }
        let(:maximum_attempts) { 5 }
        let(:unlock_in) { 1.hour }
      end
    end
  
    describe "rememberable" do
      it_behaves_like "devise rememberable", :confirmed_store do
        # Rememberable Configuration
        let(:remember_for) { 2.weeks }
      end
    end
  
    describe "timeoutable" do
      it_behaves_like "devise timeoutable", :confirmed_store do
        # Timeoutable Configuration
        let(:timeout_in) { 30.minutes }
      end
    end  

    describe "confirmable" do  
      it_behaves_like "devise confirmable", :approved_store do
        # Confirmable Configuration
        let(:reconfirmable) { true }
        let(:confirmation_keys) { [:email] }
      end
    end
  end
end