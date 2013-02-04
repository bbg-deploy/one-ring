require 'spec_helper'

describe Admin, :admin => true do
  # Model & Factory Validation
  #----------------------------------------------------------------------------
  describe "factory validation", :factory_validation => true do
    specify { Admin.new.should be_an_instance_of(Admin) }

    describe "admin factory" do
      let(:admin) { FactoryGirl.create(:admin) }

      it_behaves_like "valid record", :admin
      
      it "has admin_assignments" do
        admin.admin_assignments.should_not be_empty
      end

      it "has admin_roles" do
        admin.admin_roles.should_not be_empty
      end
    end
  end

  # Associations
  #----------------------------------------------------------------------------
  describe "associations", :associations => true do    
  end

  # Attributes
  #----------------------------------------------------------------------------
  describe "attributes", :attributes => true do
    # This performs the standard checks for usernames, emails, passwords, etc.
    it_behaves_like "devise attributes (employee)", :admin

    describe "first_name" do
      it_behaves_like "attr_accessible", :admin, :first_name,
        ["tHomAS", "Chris Topher", "O'Connelly", "12Street"], #Valid values
        [nil, "!", "(Chris);"] #Invalid values
    end
  
    describe "middle_name" do
      it_behaves_like "attr_accessible", :admin, :middle_name,
        [nil, "tHomAS", "Chris Topher", "O'Connelly", "12Street"], #Valid values
        ["!", "(Chris);"] #Invalid values
    end
  
    describe "last_name" do
      it_behaves_like "attr_accessible", :admin, :last_name,
        ["tHomAS", "Chris Topher", "O'Connelly", "12Street"], #Valid values
        [nil, "!", "(Chris);"] #Invalid values
    end
  
    describe "date_of_birth" do
      it_behaves_like "attr_accessible", :admin, :date_of_birth,
        [21.years.ago, 43.years.ago], #Valid values
        [nil, 17.years.ago, 5.years.ago] #Invalid values
    end
  end
  
  # Behavior
  #----------------------------------------------------------------------------
  describe "behavior", :behavior => true do
    describe "authentication", :authentication => true do
      it_behaves_like "devise authenticatable", :admin do
        # Authentication Configuration
        let(:domain) { "credda.com" }
        let(:case_insensitive_keys) { [:email] }
        let(:strip_whitespace_keys) { [:email] }
        let(:authentication_keys) { [:login] }
      end
      
      it_behaves_like "devise recoverable", :admin do
        # Recoverable Configuration
        let(:reset_password_keys) { [:email] }
        let(:reset_password_within) { 6.hours }
      end
  
      it_behaves_like "devise lockable", :admin do
        # Lockable Configuration
        let(:unlock_keys) { [:email] }
        let(:unlock_strategy) { :both }
        let(:maximum_attempts) { 10 }
        let(:unlock_in) { 1.hour }
      end
  
      it_behaves_like "devise rememberable", :admin do
        # Rememberable Configuration
        let(:remember_for) { 2.weeks }
      end
  
      it_behaves_like "devise timeoutable", :admin do
        # Timeoutable Configuration
        let(:timeout_in) { 30.minutes }
      end
  
      it_behaves_like "devise confirmable", :admin do
        # Confirmable Configuration
        let(:reconfirmable) { true }
        let(:confirmation_keys) { [:email] }
      end
    end
  end
end