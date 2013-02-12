require 'spec_helper'

describe Employee do
  # Model & Factory Validation
  #----------------------------------------------------------------------------
  describe "factory validation", :factory_validation => true do
    specify { Employee.new.should be_an_instance_of(Employee) }
  
    describe "employee factory" do
      it_behaves_like "valid record", :employee
    end

    describe "invalid_employee factory" do
      it_behaves_like "invalid record", :invalid_employee
    end

    describe "employee_attributes_hash" do
      it "creates new employee when passed to Employee" do
        attributes = FactoryGirl.build(:employee_attributes_hash)
        employee = Employee.create(attributes)
        employee.should be_valid
      end
    end
  end

  # Database
  #----------------------------------------------------------------------------
  describe "database", :database => true do
    # Account Information
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
  end

  # Associations
  #----------------------------------------------------------------------------
  describe "associations", :associations => true do
  end

  # Attributes
  #----------------------------------------------------------------------------
  describe "attributes", :attributes => true do
    before(:each) do
      attributes = FactoryGirl.build(:employee_attributes_hash)
      employee = Employee.create!(attributes) 
    end

    describe "username" do
      it { should allow_mass_assignment_of(:username) }
      it { should validate_presence_of(:username) }
      it { should validate_uniqueness_of(:username) }
      it { should allow_value("Chris", "James", "tHomAS", "isexactlytwentychars").for(:username) }
      it { should_not allow_value(nil, "!", "cat", "Chris Topher", "admin", "demo", "12Street", "ithastoomanycharacters").for(:username) }

      it "downcases username" do
        employee = FactoryGirl.create(:employee, :username => "BiLLy")
        employee.username.should eq("billy")
      end

      it "strips leading whitespace" do
        employee = FactoryGirl.create(:employee, :username => " whitespace")
        employee.username.should eq("whitespace")
      end

      it "strips trailing whitespace" do
        employee = FactoryGirl.create(:employee, :username => "whitespace ")
        employee.username.should eq("whitespace")
      end

      it "does not allow whitespace in the middle" do
        employee = FactoryGirl.build(:employee, :username => "white space")
        employee.should_not be_valid
      end
    end

    describe "email" do
      it { should allow_mass_assignment_of(:email) }
      it { should validate_presence_of(:email) }
      it { should validate_confirmation_of(:email) }
      it { should validate_uniqueness_of(:email) }
      it { should allow_value("valid@credda.com").for(:email) }
      it { should_not allow_value(nil, "valid@notcredda.com", "valid.credda.com", "@credda.com").for(:email) }

      it "downcases email" do
        employee = FactoryGirl.create(:employee, :email => "TEST@credda.com")
        employee.email.should eq("test@credda.com")
      end

      it "strips leading whitespace" do
        employee = FactoryGirl.create(:employee, :email => " white@credda.com")
        employee.email.should eq("white@credda.com")
      end
      
      it "strips trailing whitespace" do
        employee = FactoryGirl.create(:employee, :email => "white@credda.com ")
        employee.email.should eq("white@credda.com")
      end

      it "strips whitespace in the middle" do
        employee = FactoryGirl.create(:employee, :email => "white @ credda.com")
        employee.email.should eq("white@credda.com")
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
  
    describe "terms agreement" do
      it { should allow_mass_assignment_of(:terms_agreement) }
      it { should validate_acceptance_of(:terms_agreement) }
      it { should allow_value("1").for(:terms_agreement) }
      it { should_not allow_value("0").for(:terms_agreement) }
    end
  end
  
  # Behavior
  #----------------------------------------------------------------------------
  describe "behavior", :behavior => true do
  end

  # Devise
  #----------------------------------------------------------------------------
  describe "devise", :devise => true do
    it_behaves_like "devise authenticatable", :employee do
      # Authentication Configuration
      let(:domain) { "notcredda.com" }
      let(:case_insensitive_keys) { [:email] }
      let(:strip_whitespace_keys) { [:email] }
      let(:authentication_keys) { [:login] }
    end
    
    it_behaves_like "devise recoverable", :employee do
      # Recoverable Configuration
      let(:reset_password_keys) { [:email] }
      let(:reset_password_within) { 6.hours }
    end

    it_behaves_like "devise lockable", :employee do
      # Lockable Configuration
      let(:unlock_keys) { [:email] }
      let(:unlock_strategy) { :both }
      let(:maximum_attempts) { 10 }
      let(:unlock_in) { 1.hour }
    end

    it_behaves_like "devise rememberable", :employee do
      # Rememberable Configuration
      let(:remember_for) { 2.weeks }
    end

    it_behaves_like "devise timeoutable", :employee do
      # Timeoutable Configuration
      let(:timeout_in) { 30.minutes }
    end

    it_behaves_like "devise confirmable", :employee do
      # Confirmable Configuration
      let(:reconfirmable) { true }
      let(:confirmation_keys) { [:email] }
    end
  end
end