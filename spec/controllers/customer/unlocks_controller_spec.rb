require 'spec_helper'

describe Customer::UnlocksController do
  include Devise::TestHelpers

  describe "routing", :routing => true do
    let(:customer) { FactoryGirl.create(:customer) }

    it { should route(:get, "/customer/unlock/new").to(:action => :new) }
    it { should route(:post, "/customer/unlock").to(:action => :create) }
    it { should route(:get, "/customer/unlock").to(:action => :show) }
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
    context "as unauthenticated, unlocked customer" do
      include_context "as unauthenticated customer"

      before(:each) do
        attributes = {:email => customer.email}
        post :create, :customer => attributes, :format => 'html'
      end

      # Parameters
#       it { should permit(:email).for(:create) }

      # Response
      it { should assign_to(:customer) }
      it { should respond_with(:success) }

      # Content
      it { should_not set_the_flash }
      it { should render_template(:new) }

      # Behavior
      it "should not send confirmation email" do
        last_email.should be_nil
      end
    end

    context "as unauthenticated, locked customer" do
      include_context "as unauthenticated, locked customer"

      describe "invalid email" do
        before(:each) do
          attributes = {:email => "invalid@email.com"}
          post :create, :customer => attributes, :format => 'html'
        end
  
        # Parameters
  #       it { should permit(:email).for(:create) }
  
        # Response
        it { should assign_to(:customer) }
        it { should respond_with(:success) }
  
        # Content
        it { should_not set_the_flash }
        it { should render_template(:new) }
      end

      describe "valid email" do
        before(:each) do
          attributes = {:email => customer.email}
          post :create, :customer => attributes, :format => 'html'
        end
  
        # Parameters
  #       it { should permit(:email).for(:create) }
  
        # Response
        it { should assign_to(:customer) }
        it { should respond_with(:redirect) }
        it { should redirect_to(new_customer_session_path) }
  
        # Content
        it { should set_the_flash[:notice].to(/email with instructions about how to unlock/) }
      end
    end
  end

  describe "#show", :show => true do

  end
end