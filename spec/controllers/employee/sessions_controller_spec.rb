require 'spec_helper'

describe Employee::SessionsController do
  include Devise::TestHelpers

  describe "routing", :routing => true do
    let(:employee) { FactoryGirl.create(:employee) }

    it { should route(:get, "/employee/sign_in").to(:action => :new) }
    it { should route(:post, "/employee/sign_in").to(:action => :create) }
    it { should route(:delete, "/employee/sign_out").to(:action => :destroy) }
  end

  describe "#new", :new => true do
    context "as unauthenticated employee" do
      include_context "as unauthenticated employee"
      before(:each) do
        get :new, :format => 'html'
      end

      # Response
      it { should assign_to(:employee) }
      it { should respond_with(:success) }

      # Content
      it { should_not set_the_flash }
      it { should render_template(:new) }
    end
    
    context "as authenticated employee" do
      include_context "as authenticated employee"
      before(:each) do
        get :new, :format => 'html'
      end

      # Response
      it { should_not assign_to(:employee) }
      it { should respond_with(:redirect) }
      it { should redirect_to(employee_home_path) }

      # Content
      it { should set_the_flash[:alert].to(/already signed in/) }
    end
  end

  describe "#create", :create => true do
    context "as unauthenticated, unconfirmed employee" do
      include_context "as unauthenticated, unconfirmed employee"

      describe "valid login" do
        before(:each) do
          attributes = {:login => employee.email, :password => employee.password}
          post :create, :employee => attributes, :format => 'html'
        end

        # Parameters
#       it { should permit(:email).for(:create) }

        # Response
        it { should_not assign_to(:employee) }
        it { should respond_with(:redirect) }
        it { should redirect_to(new_employee_session_path) }
  
        # Content
        it { should set_the_flash[:alert].to(/confirm your account before continuing/) }
      end
    end

    context "as unauthenticated employee" do
      include_context "as unauthenticated employee"

      describe "invalid login" do
        before(:each) do
          attributes = {:login => employee.email, :password => "wrongpass"}
          post :create, :employee => attributes, :format => 'html'
        end

        # Parameters
#       it { should permit(:email).for(:create) }

        # Response
        it { should_not assign_to(:employee) }
        it { should respond_with(:success) }
  
        # Content
        it { should_not set_the_flash }
        it { should render_template(:new) }
      end

      describe "valid login (email)" do
        before(:each) do
          attributes = {:login => employee.email, :password => employee.password}
          post :create, :employee => attributes, :format => 'html'
        end

        # Response
        it { should assign_to(:employee) }
        it { should respond_with(:redirect) }
        it { should redirect_to(employee_home_path) }
  
        # Content
        it { should set_the_flash[:notice].to(/Signed in successfully/) }
      end

      describe "valid login (username)" do
        before(:each) do
          attributes = {:login => employee.username, :password => employee.password}
          post :create, :employee => attributes, :format => 'html'
        end

        # Response
        it { should assign_to(:employee) }
        it { should respond_with(:redirect) }
        it { should redirect_to(employee_home_path) }
  
        # Content
        it { should set_the_flash[:notice].to(/Signed in successfully/) }
      end
    end

    context "as authenticated employee" do
      include_context "as authenticated employee"

      before(:each) do
        attributes = {:login => employee.username, :password => employee.password}
        post :create, :employee => attributes, :format => 'html'
      end

      it { should_not assign_to(:employee) }
      it { should respond_with(:redirect) }
      it { should redirect_to(employee_home_path) }

      # Content
      it { should set_the_flash[:alert].to(/already signed in/) }
    end
  end

  describe "#destroy", :destroy => true do
    context "as unauthenticated employee" do
      include_context "as unauthenticated employee"

      before(:each) do
        delete :destroy, :format => 'html'
      end

      it { should_not assign_to(:employee) }
      it { should respond_with(:redirect) }
      it { should redirect_to(home_path) }

      # Content
      it { should_not set_the_flash }
    end
    
    context "as authenticated employee" do
      include_context "as authenticated employee"

      before(:each) do
        delete :destroy, :format => 'html'
      end

      it { should_not assign_to(:employee) }
      it { should respond_with(:redirect) }
      it { should redirect_to(home_path) }

      # Content
      it { should set_the_flash[:notice].to(/Signed out successfully/) }    end
  end
end