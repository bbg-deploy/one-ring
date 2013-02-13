require 'spec_helper'

describe Customer::PaymentProfilesController do
  include Devise::TestHelpers

  describe "routing", :routing => true do
    let(:customer) { FactoryGirl.create(:customer) }
    let(:payment_profile) { FactoryGirl.create(:payment_profile) }

    it { should route(:get, "/customer/payment_methods").to(:action => :index) }
    it { should route(:get, "/customer/payment_methods/new").to(:action => :new) }
    it { should route(:post, "/customer/payment_methods").to(:action => :create) }
    it { should route(:get, "/customer/payment_methods/1").to(:action => :show, :id => 1) }
    it { should route(:get, "/customer/payment_methods/1/edit").to(:action => :edit, :id => 1) }
    it { should route(:put, "/customer/payment_methods/1").to(:action => :update, :id => 1) }
    it { should route(:delete, "/customer/payment_methods/1").to(:action => :destroy, :id => 1) }
  end

  describe "#new", :new => true do
    context "as unauthenticated customer" do
      include_context "as unauthenticated customer"
      before(:each) do
        get :new, :format => 'html'
      end

      # Response
      it { should_not assign_to(:payment_profile) }
      it { should respond_with(:redirect) }
      it { should redirect_to(new_customer_session_path) }

      # Content
      it { should set_the_flash[:alert].to(/need to sign in or sign up/) }
    end

    context "as authenticated customer" do
      include_context "as authenticated customer"
      before(:each) do
        get :new, :format => 'html'
      end

      # Response
      it { should assign_to(:payment_profile) }
      it { should respond_with(:success) }

      # Content
      it { should_not set_the_flash }
      it { should render_template(:new) }
    end
  end

  describe "#create", :create => true do
    context "as unauthenticated customer" do
      include_context "as unauthenticated customer"
      describe "creating bank account profile" do
        before(:each) do
          attributes = FactoryGirl.build(:payment_profile_bank_account_attributes_hash)
          post :create, :payment_profile => attributes, :format => 'html'
        end
  
        # Response
        it { should_not assign_to(:payment_profile) }
        it { should respond_with(:redirect) }
        it { should redirect_to(new_customer_session_path) }
  
        # Content
        it { should set_the_flash[:alert].to(/need to sign in or sign up/) }
      end

      describe "creating credit card profile" do
        before(:each) do
          attributes = FactoryGirl.build(:payment_profile_credit_card_attributes_hash)
          post :create, :payment_profile => attributes, :format => 'html'
        end
  
        # Response
        it { should_not assign_to(:payment_profile) }
        it { should respond_with(:redirect) }
        it { should redirect_to(new_customer_session_path) }
  
        # Content
        it { should set_the_flash[:alert].to(/need to sign in or sign up/) }
      end
    end

    context "as authenticated customer" do
      include_context "as authenticated customer"
      describe "creating bank account profile" do
        before(:each) do
          attributes = FactoryGirl.build(:payment_profile_bank_account_attributes_hash)
          post :create, :payment_profile => attributes, :format => 'html'
        end
  
        # Response
        it { should assign_to(:payment_profile) }
        it { should respond_with(:redirect) }
        it { should redirect_to(customer_payment_profile_path(PaymentProfile.last)) }
  
        # Content
        it { should set_the_flash[:notice].to(/Successfully created payment/) }
      end

      describe "creating credit card profile" do
        before(:each) do
          attributes = FactoryGirl.build(:payment_profile_credit_card_attributes_hash)
          post :create, :payment_profile => attributes, :format => 'html'
        end
  
        # Response
        it { should assign_to(:payment_profile) }
        it { should respond_with(:redirect) }
        it { should redirect_to(customer_payment_profile_path(PaymentProfile.last)) }
  
        # Content
        it { should set_the_flash[:notice].to(/Successfully created payment/) }
      end
    end
  end

  describe "#show", :show => true do
    context "as unauthenticated, unconfirmed customer" do
      include_context "as unauthenticated, unconfirmed customer"
      
      describe "with invalid token" do
        before(:each) do
          @request.env['QUERY_STRING'] = "confirmation_token="
          get :show, :confirmation_token => "1234234234", :format => 'html'
        end

        # Response
        it { should assign_to(:customer) }
        it { should respond_with(:success) }

        # Content
        it { should_not set_the_flash }
        it { should render_template(:new) }
      end

      describe "with valid token" do
        before(:each) do
          @request.env['QUERY_STRING'] = "confirmation_token="
          get :show, :confirmation_token => "#{customer.confirmation_token}", :format => 'html'
        end        

        # Response
        it { should assign_to(:customer) }
        it { should redirect_to(customer_home_path) }
  
        # Content
        it { should set_the_flash[:notice].to(/successfully confirmed/) }
      end
    end
    
    context "as authenticated customer" do
      include_context "as authenticated customer"

      describe "with valid token" do
        before(:each) do
          @request.env['QUERY_STRING'] = "confirmation_token="
          get :show, :confirmation_token => "#{customer.confirmation_token}", :format => 'html'
        end        

        # Response
        it { should_not assign_to(:customer) }
        it { should redirect_to(customer_home_path) }
  
        # Content
        it { should set_the_flash[:alert].to(/already signed in/) }
      end
    end
  end
end