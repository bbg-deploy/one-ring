require 'spec_helper'

describe Employee::PagesController do
  # Controller Shared Methods
  #----------------------------------------------------------------------------
  def get_home
    get :home, :format => 'html'
  end

  # Routing
  #----------------------------------------------------------------------------
  describe "routing", :routing => true do
    it { should route(:get, "/employee").to(:action => :home) }
  end

  # Methods
  #----------------------------------------------------------------------------
  describe "#home", :home => true do
    context "as unauthenticated employee" do
      include_context "with unauthenticated employee"
      before(:each) do
        get_home
      end

      # Response
      it { should respond_with(:redirect) }
      it { should redirect_to(new_employee_session_path) }

      # Content
      it { should set_the_flash[:alert].to(/need to sign in or sign up/) }
    end

    context "as authenticated employee" do
      include_context "with authenticated employee"
      before(:each) do
        get_home
      end

      # Response
      it { should respond_with(:success) }

      # Content
      it { should_not set_the_flash }
      it { should render_template(:home) }
    end

    context "as authenticated customer" do
      include_context "with authenticated customer"
      before(:each) do
        get_home
      end

      # Response
      it { should respond_with(:redirect) }
      it { should redirect_to(new_employee_session_path) }

      # Content
      it { should set_the_flash[:alert].to(/need to sign in or sign up/) }
    end

    context "as authenticated store" do
      include_context "with authenticated store"
      before(:each) do
        get_home
      end

      # Response
      it { should respond_with(:redirect) }
      it { should redirect_to(new_employee_session_path) }

      # Content
      it { should set_the_flash[:alert].to(/need to sign in or sign up/) }
    end
  end
end