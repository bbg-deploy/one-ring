require 'spec_helper'

describe Customer::AuthController do
  include Devise::TestHelpers

  describe "routing", :routing => true do
    it "is a pending example"
#    it { should route(:get, "/customer/sign_up").to(:action => :new) }
#    it { should route(:post, "/customer").to(:action => :create) }
#    it { should route(:get, "/customer/edit").to(:action => :edit) }
#    it { should route(:put, "/customer").to(:action => :update) }
#    it { should route(:delete, "/customer").to(:action => :destroy) }
#    it { should route(:get, "/customer/cancel").to(:action => :cancel) }
  end

  describe "#authorize", :authorize => true do
    context "as unauthenticated customer" do
      include_context "as unauthenticated customer"
      let(:client) { FactoryGirl.create(:client) }
      let(:redirect_uri) { "/customer/auth" }
      
      before(:each) do
        get :authorize, :client_id => client.app_id, :redirect_uri => redirect_uri, :state => 'test', :format => 'html'
        @access_grant = AccessGrant.last
      end

      # Response
      it { should_not assign_to(:customer) }
      it { should respond_with(:redirect) }
      it { should redirect_to new_customer_session_path }

      # Content
      it { should set_the_flash[:alert].to(/need to sign in or sign up/) }
    end

    context "as authenticated customer" do
      include_context "as authenticated customer"
      let(:client) { FactoryGirl.create(:client) }
      let(:redirect_uri) { "/customer/auth" }

      before(:each) do
        get :authorize, :client_id => client.app_id, :redirect_uri => redirect_uri, :state => 'test', :format => 'html'
        @access_grant = AccessGrant.last
      end

      # Response
      it { should_not assign_to(:customer) }
      it { should redirect_to("http://test.host/customer/auth?code=#{@access_grant.code}&response_type=code&state=test") }

      # Content
      it { should_not set_the_flash }
    end
  end
end