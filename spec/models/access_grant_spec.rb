require 'spec_helper'

describe AccessGrant do
  # Model & Factory Validation
  #----------------------------------------------------------------------------
  describe "factory validation", :factory_validation => true do
    specify { AccessGrant.new.should be_an_instance_of(AccessGrant) }

    describe "access_grant factory" do
      it_behaves_like "valid record", :access_grant
    end
  end

  # Database
  #----------------------------------------------------------------------------
  describe "database", :database => true do
    it { should have_db_column(:accessible_id) }
    it { should have_db_column(:accessible_type) }
    it { should have_db_column(:client_id) }
    it { should have_db_column(:code) }
  end

  # Associations
  #----------------------------------------------------------------------------
  describe "associations", :associations => true do
    describe "accessible" do
#      it_behaves_like "immutable polymorphic", :access_grant, :accessible
      it { should belong_to(:accessible) }
    end    

    describe "client" do
#      it_behaves_like "immutable belongs_to", :access_grant, :client
      it { should belong_to(:client) }
    end    
  end

  # Attributes
  #----------------------------------------------------------------------------
  describe "attributes", :attributes => true do
    describe "accessible" do
      it { should allow_mass_assignment_of(:accessible) }
      it { should validate_presence_of(:accessible) }
    end

    describe "client" do
      it { should allow_mass_assignment_of(:client) }
      it { should validate_presence_of(:client) }
    end

    describe "code" do
      it { should_not allow_mass_assignment_of(:code) }
    end

    describe "access_token" do
      it { should_not allow_mass_assignment_of(:access_token) }
    end

    describe "refresh_token" do
      it { should_not allow_mass_assignment_of(:refresh_token) }
    end

    describe "access_token_expires_at" do
      it { should_not allow_mass_assignment_of(:access_token_expires_at) }
    end
  end
    
  # Behavior
  #----------------------------------------------------------------------------
  describe "behavior", :behavior => true do
    describe "self.authenticate" do
      let(:access_grant) { FactoryGirl.create(:access_grant) }
 
      context "with invalid credentials" do
        it "returns AccessGrant object" do
          access_grant.reload
          grant = AccessGrant.authenticate(access_grant.code, access_grant.client_id)
          grant.is_a?(AccessGrant).should be_true
          grant.should eq(access_grant)
        end
      end
      context "with valid credentials" do       
        it "returns AccessGrant object" do
          access_grant.reload
          grant = AccessGrant.authenticate(access_grant.code, "123")
          grant.should be_nil
        end
      end
    end

    describe "self.authenticate" do
      let(:access_grant) { FactoryGirl.create(:access_grant) }
      it "should append correct data" do
        uri = "www.google.com"
        redirect = access_grant.redirect_uri_for(uri)
        redirect.should eq("www.google.com?code=#{access_grant.code}&response_type=code")
      end
    end
    
    describe "generate_tokens" do
      it "is a pending example"
    end
  end
end