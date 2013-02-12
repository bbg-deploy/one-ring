require 'spec_helper'

describe Employee::UnlocksController do
  include Devise::TestHelpers

  describe "routing", :routing => true do
    let(:employee) { FactoryGirl.create(:employee) }

    it { should route(:get, "/employee/unlock/new").to(:action => :new) }
    it { should route(:post, "/employee/unlock").to(:action => :create) }
    it { should route(:get, "/employee/unlock").to(:action => :show) }
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
    context "as unauthenticated, unlocked employee" do
      include_context "as unauthenticated employee"

      before(:each) do
        attributes = {:email => employee.email}
        post :create, :employee => attributes, :format => 'html'
      end

      # Parameters
#       it { should permit(:email).for(:create) }

      # Response
      it { should assign_to(:employee) }
      it { should respond_with(:success) }

      # Content
      it { should_not set_the_flash }
      it { should render_template(:new) }

      # Behavior
      it "should not send confirmation email" do
        last_email.should be_nil
      end
    end

    context "as unauthenticated, locked employee" do
      include_context "as unauthenticated, locked employee"

      describe "invalid email" do
        before(:each) do
          attributes = {:email => "invalid@email.com"}
          post :create, :employee => attributes, :format => 'html'
        end
  
        # Parameters
  #       it { should permit(:email).for(:create) }
  
        # Response
        it { should assign_to(:employee) }
        it { should respond_with(:success) }
  
        # Content
        it { should_not set_the_flash }
        it { should render_template(:new) }
      end

      describe "valid email" do
        before(:each) do
          attributes = {:email => employee.email}
          post :create, :employee => attributes, :format => 'html'
        end
  
        # Parameters
  #       it { should permit(:email).for(:create) }
  
        # Response
        it { should assign_to(:employee) }
        it { should respond_with(:redirect) }
        it { should redirect_to(new_employee_session_path) }
  
        # Content
        it { should set_the_flash[:notice].to(/email with instructions about how to unlock/) }
      end
    end

    context "as authenticated employee" do
      include_context "as authenticated employee"
 
      before(:each) do
        attributes = {:email => employee.email}
        post :create, :employee => attributes, :format => 'html'
      end

       # Response
      it { should_not assign_to(:employee) }
      it { should respond_with(:redirect) }
      it { should redirect_to(employee_home_path) }

      # Content
      it { should set_the_flash[:alert].to(/already signed in/) }
    end
  end

  describe "#show", :show => true do
    context "as unauthenticated, locked employee" do
      include_context "as unauthenticated, locked employee"
      
      describe "without token" do
        before(:each) do
          get :show, :format => 'html'
        end

        # Response
        it { should assign_to(:employee) }
        it { should respond_with(:success) }

        # Content
        it { should_not set_the_flash }
        it { should render_template(:new) }
      end

      describe "with invalid token" do
        before(:each) do
          @request.env['QUERY_STRING'] = "unlock_token="
          get :show, :unlock_token => "1234234234", :format => 'html'
        end

        # Response
        it { should assign_to(:employee) }
        it { should respond_with(:success) }

        # Content
        it { should_not set_the_flash }
        it { should render_template(:new) }
      end

      describe "with valid token" do
        before(:each) do
          @request.env['QUERY_STRING'] = "unlock_token="
          get :show, :unlock_token => "#{employee.unlock_token}", :format => 'html'
        end        

        # Response
        it { should assign_to(:employee) }
        it { should redirect_to(new_employee_session_path) }
  
        # Content
        it { should set_the_flash[:notice].to(/unlocked successfully. Please sign in/) }
      end
    end

    context "as authenticated employee" do
      include_context "as authenticated employee"
 
      before(:each) do
        @request.env['QUERY_STRING'] = "unlock_token="
        get :show, :unlock_token => "abcdef", :format => 'html'
      end        

       # Response
      it { should_not assign_to(:employee) }
      it { should respond_with(:redirect) }
      it { should redirect_to(employee_home_path) }

      # Content
      it { should set_the_flash[:alert].to(/already signed in/) }
    end
  end
end