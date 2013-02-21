require 'spec_helper'

describe AuthController do
  include Devise::TestHelpers

  describe "routing", :routing => true do
    it { should route(:get, "/customer/oauth/authorize").to(:action => :authorize) }
    it { should route(:get, "/customer/oauth/access_token").to(:action => :access_token) }
  end

  describe "#authorize", :authorize => true do
    context "as unauthenticated customer" do
      include_context "as unauthenticated customer"
      let(:client) { FactoryGirl.create(:client) }
      
      before(:each) do
        get :authorize, :client_id => client.app_id, :state => 'test', :format => 'html'
        @access_grant = AccessGrant.last
      end

      # Response
      it { should respond_with(:redirect) }
      it { should redirect_to new_customer_session_path }

      # Content
      it { should set_the_flash[:alert].to(/need to sign in or sign up/) }
    end

    context "as authenticated customer" do
      include_context "as authenticated customer"
      let(:client) { FactoryGirl.create(:client) }

      before(:each) do
        get :authorize, :client_id => client.app_id, :state => 'test', :format => 'html'
        @access_grant = AccessGrant.last
      end

      # Response
      it { should respond_with(:redirect) }
      it { should redirect_to("#{client.redirect_uri}?code=#{@access_grant.code}&response_type=code&state=test") }

      # Content
      it { should_not set_the_flash }
    end
  end

  describe "#access_token", :access_token => true do
    context "as unauthenticated customer" do
      include_context "as unauthenticated customer"
      
      context "with invalid id and secret" do
        let(:client) { FactoryGirl.create(:client) }
        
        before(:each) do
          get :access_token, :client_id => client.app_id, :client_secret => SecureRandom.hex, :format => 'html'
        end
  
        # Response
        it { should respond_with(:success) }
        it { should respond_with_content_type(:json) }
  
        # Content
        it { should_not set_the_flash }
        it "responds with error" do
          response.body.should eq("{\"error\":\"Could not find application\"}")
        end
      end

      context "with valid id and secret, no code" do
        let(:client) { FactoryGirl.create(:client) }
        
        before(:each) do
          get :access_token, :client_id => client.app_id, :client_secret => client.app_access_token, :format => 'html'
        end
  
        # Response
        it { should respond_with(:success) }
        it { should respond_with_content_type(:json) }
  
        # Content
        it { should_not set_the_flash }
        it "responds with error" do
          response.body.should eq("{\"error\":\"Could not authenticate access code\"}")
        end
      end

      context "with valid id, secret, and code", :failing => true do
        let(:client) { FactoryGirl.create(:client) }
        let(:access_grant) { FactoryGirl.create(:access_grant, :client => client)}
        let(:code) { SecureRandom.hex }
        
        before(:each) do
          get :access_token, :client_id => client.app_id, :client_secret => client.app_access_token, :code => access_grant.code, :format => 'html'
        end
  
        # Response
        it { should respond_with(:success) }
        it { should respond_with_content_type(:json) }
  
        # Content
        it { should_not set_the_flash }
        it "responds with error" do
          response.body.should eq("{\"access_token\":\"#{access_grant.access_token}\",\"refresh_token\":\"#{access_grant.refresh_token}\",\"expires_in\":1800}")
        end
      end
    end

    context "as authenticated customer" do
      include_context "as authenticated customer"
      let(:client) { FactoryGirl.create(:client) }

      context "with invalid id and secret" do
        let(:client) { FactoryGirl.create(:client) }
        
        before(:each) do
          get :access_token, :client_id => client.app_id, :client_secret => SecureRandom.hex, :format => 'html'
        end
  
        # Response
        it { should respond_with(:success) }
        it { should respond_with_content_type(:json) }
  
        # Content
        it { should_not set_the_flash }
        it "responds with error" do
          response.body.should eq("{\"error\":\"Could not find application\"}")
        end
      end

      context "with valid id and secret, no code" do
        let(:client) { FactoryGirl.create(:client) }
        
        before(:each) do
          get :access_token, :client_id => client.app_id, :client_secret => client.app_access_token, :format => 'html'
        end
  
        # Response
        it { should respond_with(:success) }
        it { should respond_with_content_type(:json) }
  
        # Content
        it { should_not set_the_flash }
        it "responds with error" do
          response.body.should eq("{\"error\":\"Could not authenticate access code\"}")
        end
      end

      context "with valid id, secret, and code", :failing => true do
        let(:client) { FactoryGirl.create(:client) }
        let(:access_grant) { FactoryGirl.create(:access_grant, :client => client)}
        let(:code) { SecureRandom.hex }
        
        before(:each) do
          get :access_token, :client_id => client.app_id, :client_secret => client.app_access_token, :code => access_grant.code, :format => 'html'
        end
  
        # Response
        it { should respond_with(:success) }
        it { should respond_with_content_type(:json) }
  
        # Content
        it { should_not set_the_flash }
        it "responds with error" do
          response.body.should eq("{\"access_token\":\"#{access_grant.access_token}\",\"refresh_token\":\"#{access_grant.refresh_token}\",\"expires_in\":1800}")
        end
      end
    end
  end
end