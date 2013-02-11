require 'spec_helper'

describe Customer::SessionsController do
  include Devise::TestHelpers

  describe "routing", :routing => true do
    let(:customer) { FactoryGirl.create(:customer) }

    it { should route(:get, "/customer/sign_in").to(:action => :new) }
    it { should route(:post, "/customer/sign_in").to(:action => :create) }
    it { should route(:delete, "/customer/sign_out").to(:action => :destroy) }
  end

  describe "#new", :new => true do
    context "as unauthenticated customer" do
      include_context "as unauthenticated customer"
      before(:each) do
        get :new, :format => 'html'
      end

      # Response
      it { should assign_to(:customer) }
      it { should respond_with(:success) }

      # Content
      it { should_not set_the_flash }
      it { should render_template(:new) }
    end
    
    context "as authenticated customer" do
      include_context "as authenticated customer"
      before(:each) do
        get :new, :format => 'html'
      end

      # Response
      it { should_not assign_to(:customer) }
      it { should respond_with(:redirect) }
      it { should redirect_to(customer_home_path) }

      # Content
      it { should set_the_flash[:alert].to(/already signed in/) }
    end
  end

  describe "#create", :create => true do
    context "as unauthenticated, unconfirmed customer" do
      include_context "as unauthenticated, unconfirmed customer"

      describe "valid login" do
        before(:each) do
          attributes = {:login => customer.email, :password => customer.password}
          post :create, :customer => attributes, :format => 'html'
        end

        # Parameters
#       it { should permit(:email).for(:create) }

        # Response
        it { should_not assign_to(:customer) }
        it { should respond_with(:redirect) }
        it { should redirect_to(new_customer_session_path) }
  
        # Content
        it { should set_the_flash[:alert].to(/confirm your account before continuing/) }
      end
    end

    context "as unauthenticated customer" do
      include_context "as unauthenticated customer"

      describe "invalid login" do
        before(:each) do
          attributes = {:login => customer.email, :password => "wrongpass"}
          post :create, :customer => attributes, :format => 'html'
        end

        # Parameters
#       it { should permit(:email).for(:create) }

        # Response
        it { should_not assign_to(:customer) }
        it { should respond_with(:success) }
  
        # Content
        it { should_not set_the_flash }
        it { should render_template(:new) }
      end

      describe "valid login (email)" do
        before(:each) do
          attributes = {:login => customer.email, :password => customer.password}
          post :create, :customer => attributes, :format => 'html'
        end

        # Response
        it { should assign_to(:customer) }
        it { should respond_with(:redirect) }
        it { should redirect_to(customer_home_path) }
  
        # Content
        it { should set_the_flash[:notice].to(/Signed in successfully/) }
      end

      describe "valid login (username)" do
        before(:each) do
          attributes = {:login => customer.username, :password => customer.password}
          post :create, :customer => attributes, :format => 'html'
        end

        # Response
        it { should assign_to(:customer) }
        it { should respond_with(:redirect) }
        it { should redirect_to(customer_home_path) }
  
        # Content
        it { should set_the_flash[:notice].to(/Signed in successfully/) }
      end
    end

    context "as authenticated customer" do
      include_context "as authenticated customer"

      before(:each) do
        attributes = {:login => customer.username, :password => customer.password}
        post :create, :customer => attributes, :format => 'html'
      end

      it { should_not assign_to(:customer) }
      it { should respond_with(:redirect) }
      it { should redirect_to(customer_home_path) }

      # Content
      it { should set_the_flash[:alert].to(/already signed in/) }
    end
  end

  describe "#destroy", :destroy => true do
    context "as unauthenticated customer" do
      include_context "as unauthenticated customer"

      before(:each) do
        delete :destroy, :format => 'html'
      end

      it { should_not assign_to(:customer) }
      it { should respond_with(:redirect) }
      it { should redirect_to(home_path) }

      # Content
      it { should_not set_the_flash }
    end
    
    context "as authenticated customer" do
      include_context "as authenticated customer"

      before(:each) do
        delete :destroy, :format => 'html'
      end

      it { should_not assign_to(:customer) }
      it { should respond_with(:redirect) }
      it { should redirect_to(home_path) }

      # Content
      it { should set_the_flash[:notice].to(/Signed out successfully/) }    end
  end
end