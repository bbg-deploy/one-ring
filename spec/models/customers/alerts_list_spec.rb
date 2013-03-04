require 'spec_helper'

describe AlertsList do
  # Model & Factory Validation
  #----------------------------------------------------------------------------
  describe "factory validation", :factory_validation => true do
    specify { AlertsList.new.should be_an_instance_of(AlertsList) }
  
    describe "alerts_list factory" do
      it_behaves_like "valid record", :alerts_list
    end
    
    describe "alerts_list_attributes_hash" do
      it "creates new alerts_list when passed to AlertsList" do
        attributes = FactoryGirl.build(:alerts_list_attributes_hash)
        list = AlertsList.create(attributes)
        list.should be_valid
      end
    end
  end

  # Database
  #----------------------------------------------------------------------------
  describe "database", :database => true do
    it { should have_db_column(:customer_id) }
    it { should have_db_column(:mail) }
    it { should have_db_column(:email) }
    it { should have_db_column(:sms) }
    it { should have_db_column(:phone) }
  end

  # Associations
  #----------------------------------------------------------------------------
  describe "associations", :associations => true do
    describe "customer" do
      it { should belong_to(:customer) }
    end
  end

  # Attributes
  #----------------------------------------------------------------------------
  describe "attributes", :attributes => true do
    describe "email" do
      it { should allow_mass_assignment_of(:mail) }
      it { should allow_value("1", "0").for(:mail) }
      it { should_not allow_value(nil, "!").for(:mail) }
    end

    describe "email" do
      it { should allow_mass_assignment_of(:email) }
      it { should allow_value("1", "0").for(:email) }
      it { should_not allow_value(nil, "!").for(:email) }
    end

    describe "sms" do
      it { should allow_mass_assignment_of(:sms) }
      it { should allow_value("1", "0").for(:sms) }
      it { should_not allow_value(nil, "!").for(:sms) }
    end

    describe "phone" do
      it { should allow_mass_assignment_of(:phone) }
      it { should allow_value("1", "0").for(:phone) }
      it { should_not allow_value(nil, "!").for(:phone) }
    end
  end
  
  # Public Methods
  #----------------------------------------------------------------------------
  describe "public methods", :public_methods => true do
    describe "mailable" do
      context "with mail=false" do
        it "returns false" do
          list = FactoryGirl.create(:alerts_list, :mail => "0")
          list.mailable?.should be_false
        end
      end

      context "with mail=true" do
        it "returns true" do
          list = FactoryGirl.create(:alerts_list, :mail => "1")
          list.mailable?.should be_true
        end
      end
    end

    describe "emailable" do
      context "with email=false" do
        it "returns false" do
          list = FactoryGirl.create(:alerts_list, :email => "0")
          list.emailable?.should be_false
        end
      end

      context "with email=true" do
        it "returns true" do
          list = FactoryGirl.create(:alerts_list, :email => "1")
          list.emailable?.should be_true
        end
      end
    end

    describe "smsable" do
      context "with sms=false" do
        it "returns false" do
          list = FactoryGirl.create(:alerts_list, :sms => "0")
          list.smsable?.should be_false
        end
      end

      context "with sms=true" do
        it "returns true" do
          list = FactoryGirl.create(:alerts_list, :sms => "1")
          list.smsable?.should be_true
        end
      end
    end

    describe "phonable" do
      context "with phone=false" do
        it "returns false" do
          list = FactoryGirl.create(:alerts_list, :phone => "0")
          list.phonable?.should be_false
        end
      end

      context "with phone=true" do
        it "returns true" do
          list = FactoryGirl.create(:alerts_list, :phone => "1")
          list.phonable?.should be_true
        end
      end
    end
  end
end