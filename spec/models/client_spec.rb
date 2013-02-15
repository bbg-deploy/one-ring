require 'spec_helper'

describe Client do
  # Model & Factory Validation
  #----------------------------------------------------------------------------
  describe "factory validation", :factory_validation => true do
    specify { Client.new.should be_an_instance_of(Client) }
  
    describe "client factory" do
      it_behaves_like "valid record", :client
    end

    describe "client_attributes_hash" do
      it "creates new client when passed to Client" do
        attributes = FactoryGirl.build(:client_attributes_hash)
        client = Client.create(attributes)
        client.should be_valid
      end
    end
  end

  # Database
  #----------------------------------------------------------------------------
  describe "database", :database => true do
    # Account Information
    it { should have_db_column(:name) }
    it { should have_db_column(:app_id) }
    it { should have_db_index(:app_id) }
    it { should have_db_column(:app_access_token) }
    it { should have_db_index(:app_access_token) }
  end

  # Associations
  #----------------------------------------------------------------------------
  describe "associations", :associations => true do
  end

  # Attributes
  #----------------------------------------------------------------------------
  describe "attributes", :attributes => true do
    before(:each) do
      attributes = FactoryGirl.build(:client_attributes_hash)
      client = Client.create!(attributes)
    end

    describe "name" do
      it { should allow_mass_assignment_of(:name) }
      it { should validate_presence_of(:name) }
      it { should allow_value("LeaseApp", "BillingApp", "isexactlytwentychars").for(:name) }
      it { should ensure_length_of(:name).is_at_least(6).is_at_most(20) }
      it { should_not allow_value(nil, "!", "cat").for(:name) }

      it "strips leading whitespace" do
        client = FactoryGirl.create(:client, :name => " whitespace")
        client.name.should eq("whitespace")
      end

      it "strips trailing whitespace" do
        client = FactoryGirl.create(:client, :name => "whitespace ")
        client.name.should eq("whitespace")
      end

      it "does not allow whitespace in the middle" do
        client = FactoryGirl.build(:client, :name => "white space")
        client.should_not be_valid
      end
    end

    describe "app_id" do
      it { should allow_mass_assignment_of(:app_id) }
      it { should validate_presence_of(:app_id) }
      it { should validate_confirmation_of(:app_id) }
      it { should validate_uniqueness_of(:app_id) }
      it { should ensure_length_of(:app_id).is_at_least(6).is_at_most(20) }
      it { should allow_value("thisappid").for(:app_id) }
      it { should_not allow_value(nil, "!", "cat", "thisappid?", "this app", " thisapp").for(:app_id) }
    end
  end
  
  # Behavior
  #----------------------------------------------------------------------------
  describe "behavior", :behavior => true do
  end
end