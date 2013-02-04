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

    describe "customer_with_lease_applications factory" do
      it_behaves_like "valid record", :customer_with_lease_applications
    
      it "has leases" do
        customer = FactoryGirl.create(:customer_with_lease_applications)
        customer.lease_applications.should_not be_empty
      end      
    end
  end

  # Associations
  #----------------------------------------------------------------------------
  describe "associations", :associations => true do
    describe "lease_applications" do
    end
    
    describe "leases" do
    end

    describe "payment_profiles" do
      describe "dependent destroy", :dependent_destroy => true do
        let(:customer) { FactoryGirl.create(:customer) }
        it_behaves_like "dependent destroy", :customer_with_payment_profiles, :payment_profiles
      end
    end

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
    describe "unclaimed_lease_applications", :method => true do
      context "with exact email match" do
        let(:customer) { FactoryGirl.create(:customer, :email => "behavior@test.com") }
        let(:unclaimed_lease_application_1) { FactoryGirl.create(:unclaimed_lease_application, :matching_email => "behavior@tst.com") }
        let(:unclaimed_lease_application_2) { FactoryGirl.create(:unclaimed_lease_application, :matching_email => "random@email.com") }

        it "returns correct lease_applications" do
          customer.reload
          unclaimed_lease_application_1.reload
          unclaimed_lease_application_2.reload
          customer.unclaimed_lease_applications.should eq([unclaimed_lease_application_1])
        end
      end

      context "with fuzzy email matches" do
        let(:customer) { FactoryGirl.create(:customer, :email => "behavior@test.com") }
        let(:unclaimed_lease_application_1) { FactoryGirl.create(:unclaimed_lease_application, :matching_email => "bhavior@tst.com") }
        let(:unclaimed_lease_application_2) { FactoryGirl.create(:unclaimed_lease_application, :matching_email => "bhvior@tst.com") }
        let(:unclaimed_lease_application_3) { FactoryGirl.create(:unclaimed_lease_application, :matching_email => "random@email.com") }

        it "returns correct lease_applications" do
          customer.reload
          unclaimed_lease_application_1.reload
          unclaimed_lease_application_2.reload
          unclaimed_lease_application_3.reload
          customer.unclaimed_lease_applications.should eq([unclaimed_lease_application_1, unclaimed_lease_application_2])
        end
      end
    end

    describe "claimed_lease_applications", :method => true do
      let(:customer) { FactoryGirl.create(:customer) }
      let(:claimed_lease_application_1) { FactoryGirl.create(:claimed_lease_application, :customer => customer) }
      let(:claimed_lease_application_2) { FactoryGirl.create(:claimed_lease_application, :customer => customer) }
      let(:submitted_lease_application_1) { FactoryGirl.create(:submitted_lease_application, :customer => customer) }

      it "returns correct leases" do
        customer.lease_applications << claimed_lease_application_1
        customer.lease_applications << claimed_lease_application_2
        customer.lease_applications << submitted_lease_application_1
        customer.claimed_lease_applications.should eq([claimed_lease_application_1, claimed_lease_application_2])
      end
    end

    describe "submitted_lease_applications", :method => true do
      let(:customer) { FactoryGirl.create(:customer) }
      let(:claimed_lease_application_1) { FactoryGirl.create(:claimed_lease_application, :customer => customer) }
      let(:submitted_lease_application_1) { FactoryGirl.create(:submitted_lease_application, :customer => customer) }
      let(:submitted_lease_application_2) { FactoryGirl.create(:submitted_lease_application, :customer => customer) }

      it "returns correct lease_applications" do
        customer.lease_applications << claimed_lease_application_1
        customer.lease_applications << submitted_lease_application_1
        customer.lease_applications << submitted_lease_application_2
        customer.submitted_lease_applications.should eq([submitted_lease_application_1, submitted_lease_application_2])
      end
    end

    describe "approved_lease_applications", :method => true do
      let(:customer) { FactoryGirl.create(:customer) }
      let(:approved_lease_application_1) { FactoryGirl.create(:approved_lease_application, :customer => customer) }
      let(:approved_lease_application_2) { FactoryGirl.create(:approved_lease_application, :customer => customer) }
      let(:denied_lease_application_1) { FactoryGirl.create(:denied_lease_application, :customer => customer) }

      it "returns correct leases" do
        customer.lease_applications << approved_lease_application_1
        customer.lease_applications << approved_lease_application_2
        customer.lease_applications << denied_lease_application_1
        customer.approved_lease_applications.should eq([approved_lease_application_1, approved_lease_application_2])
      end
    end

    describe "denied_lease_applications", :method => true do
      let(:customer) { FactoryGirl.create(:customer) }
      let(:approved_lease_application_1) { FactoryGirl.create(:approved_lease_application, :customer => customer) }
      let(:denied_lease_application_1) { FactoryGirl.create(:denied_lease_application, :customer => customer) }
      let(:denied_lease_application_2) { FactoryGirl.create(:denied_lease_application, :customer => customer) }

      it "returns correct lease_applications" do
        customer.lease_applications << approved_lease_application_1
        customer.lease_applications << denied_lease_application_1
        customer.lease_applications << denied_lease_application_2
        customer.denied_lease_applications.should eq([denied_lease_application_1, denied_lease_application_2])
      end
    end

    describe "finalized_lease_applications", :method => true do
      let(:customer) { FactoryGirl.create(:customer) }
      let(:denied_lease_application_1) { FactoryGirl.create(:denied_lease_application, :customer => customer) }
      let(:finalized_lease_application_1) { FactoryGirl.create(:finalized_lease_application, :customer => customer) }
      let(:finalized_lease_application_2) { FactoryGirl.create(:finalized_lease_application, :customer => customer) }

      it "returns correct lease_applications" do
        customer.lease_applications << denied_lease_application_1
        customer.lease_applications << finalized_lease_application_1
        customer.lease_applications << finalized_lease_application_2
        customer.finalized_lease_applications.should eq([finalized_lease_application_1, finalized_lease_application_2])
      end
    end

    describe "completed_lease_applications", :method => true do
      let(:customer) { FactoryGirl.create(:customer) }
      let(:denied_lease_application_1) { FactoryGirl.create(:denied_lease_application, :customer => customer) }
      let(:completed_lease_application_1) { FactoryGirl.create(:completed_lease_application, :customer => customer) }
      let(:completed_lease_application_2) { FactoryGirl.create(:completed_lease_application, :customer => customer) }

      it "returns correct lease_applications" do
        customer.lease_applications << denied_lease_application_1
        customer.lease_applications << completed_lease_application_1
        customer.lease_applications << completed_lease_application_2
        customer.completed_lease_applications.should eq([completed_lease_application_1, completed_lease_application_2])
      end
    end
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