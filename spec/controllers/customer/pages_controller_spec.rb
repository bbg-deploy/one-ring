require 'spec_helper'

describe Customer::PagesController do
  # Controller Shared Methods
  #----------------------------------------------------------------------------
  def do_get_home
    get :home, :format => 'html'
  end

  # Routing
  #----------------------------------------------------------------------------
  describe "routing", :routing => true do
    it { should route(:get, "/customer").to(:action => :home) }
  end

  # Methods
  #----------------------------------------------------------------------------
  describe "#home", :home => true do
    context "as unauthenticated customer" do
      include_context "with unauthenticated customer"

      before(:each) do
        do_get_home
      end

      # Variables
      it "should not have current user" do
        subject.current_user.should be_nil
      end

      # Response
      it { should respond_with(:redirect) }
      it { should redirect_to(new_customer_session_path) }

      # Content      
      it { should set_the_flash[:alert].to(/need to sign in or sign up/) }
    end

    context "as authenticated customer" do
      include_context "with authenticated customer"

      before(:each) do
        do_get_home
      end

      # Variables
      it "should have current customer" do
        subject.current_customer.should_not be_nil
      end

      # Response
      it { should respond_with(:success) }

      # Content
      it { should_not set_the_flash }
      it { should render_template(:home) }
      it { should render_template("layouts/customer_layout") }
    end

    context "as authenticated store" do
      include_context "with authenticated store"

      before(:each) do
        do_get_home
      end

      # Variables
      it "should have current store" do
        subject.current_store.should_not be_nil
      end

      # Response
      it { should_not assign_to(:customer) }
      it { should respond_with(:redirect) }
      it { should redirect_to(new_customer_session_path) }

      # Content
      it { should set_the_flash[:alert].to(/need to sign in or sign up/) }
    end

    context "as authenticated employee" do
      include_context "with authenticated employee"

      before(:each) do
        do_get_home
      end

      # Variables
      it "should have current employee" do
        subject.current_employee.should_not be_nil
      end

      # Response
      it { should_not assign_to(:customer) }
      it { should respond_with(:redirect) }
      it { should redirect_to(new_customer_session_path) }

      # Content
      it { should set_the_flash[:alert].to(/need to sign in or sign up/) }
    end
  end
end