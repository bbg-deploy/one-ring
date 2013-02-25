require 'spec_helper'

describe Employee::UnlocksController do
  describe "routing", :routing => true do
    it { should route(:get, "/employee/unlock/new").to(:action => :new) }
    it { should route(:post, "/employee/unlock").to(:action => :create) }
    it { should route(:get, "/employee/unlock").to(:action => :show) }
  end

  describe "#new", :new => true do
    context "as unauthenticated employee" do
      include_context "with unauthenticated employee"

      before(:each) do
        @request.env["devise.mapping"] = Devise.mappings[:employee]
        get :new, :format => 'html'
      end

      # Variables
      it "should not have current user" do
        subject.current_user.should be_nil
        subject.current_employee.should be_nil
      end

      # Response
      it { should assign_to(:employee) }
      it { should respond_with(:success) }

      # Content
      it { should_not set_the_flash }
      it { should render_template(:new) }
    end

    context "as authenticated employee" do
      include_context "with authenticated employee"
 
      before(:each) do
        @request.env["devise.mapping"] = Devise.mappings[:employee]
        get :new, :format => 'html'
      end

      # Variables
      it "should have current employee" do
        subject.current_user.should_not be_nil
        subject.current_employee.should_not be_nil
      end

       # Response
      it { should_not assign_to(:employee) }
      it { should respond_with(:redirect) }
      it { should redirect_to(employee_home_path) }

      # Content
      it { should set_the_flash[:alert].to(/already signed in/) }
    end

    context "as authenticated customer" do
      include_context "with authenticated customer"
      before(:each) do
        @request.env["devise.mapping"] = Devise.mappings[:employee]
        get :new, :format => 'html'
      end

      # Variables
      it "should have current customer" do
        subject.current_user.should_not be_nil
        subject.current_employee.should be_nil
        subject.current_customer.should_not be_nil
      end

      # Response
      it { should_not assign_to(:employee) }
      it { should respond_with(:redirect) }
      it { should redirect_to(employee_scope_conflict_path) }

      # Content
      it { should_not set_the_flash }
    end

    context "as authenticated store" do
      include_context "with authenticated store"
      before(:each) do
        @request.env["devise.mapping"] = Devise.mappings[:employee]
        get :new, :format => 'html'
      end

      # Variables
      it "should have current store" do
        subject.current_user.should_not be_nil
        subject.current_employee.should be_nil
        subject.current_store.should_not be_nil
      end

      # Response
      it { should_not assign_to(:employee) }
      it { should respond_with(:redirect) }
      it { should redirect_to(employee_scope_conflict_path) }

      # Content
      it { should_not set_the_flash }
    end
  end

  describe "#create", :create => true do
    context "as unlocked employee" do
      include_context "with unauthenticated employee"

      before(:each) do
        @request.env["devise.mapping"] = Devise.mappings[:employee]
        attributes = {:email => employee.email}
        post :create, :employee => attributes, :format => 'html'
      end

      # Parameters
#       it { should permit(:email).for(:create) }

      # Variables
      it "should not have current user" do
        subject.current_user.should be_nil
        subject.current_employee.should be_nil
      end

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

    context "as locked employee" do
      include_context "with locked employee"

      describe "invalid email" do
        before(:each) do
          @request.env["devise.mapping"] = Devise.mappings[:employee]
          attributes = {:email => "invalid@email.com"}
          post :create, :employee => attributes, :format => 'html'
        end
  
        # Parameters
  #       it { should permit(:email).for(:create) }
  
        # Variables
        it "should not have current user" do
          subject.current_user.should be_nil
          subject.current_employee.should be_nil
        end

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

      describe "valid email" do
        before(:each) do
          @request.env["devise.mapping"] = Devise.mappings[:employee]
          attributes = {:email => employee.email}
          post :create, :employee => attributes, :format => 'html'
        end
  
        # Parameters
  #       it { should permit(:email).for(:create) }
  
        # Variables
        it "should not have current user" do
          subject.current_user.should be_nil
          subject.current_employee.should be_nil
        end

        # Response
        it { should assign_to(:employee) }
        it { should respond_with(:redirect) }
        it { should redirect_to(new_employee_session_path) }
  
        # Content
        it { should set_the_flash[:notice].to(/email with instructions about how to unlock/) }

        # Behavior
        it "should send confirmation email to employee" do
          last_email.should_not be_nil
          last_email.to.should eq([employee.email])
        end
      end
    end

    context "as authenticated employee" do
      include_context "with authenticated employee"
 
      before(:each) do
        @request.env["devise.mapping"] = Devise.mappings[:employee]
        attributes = {:email => employee.email}
        post :create, :employee => attributes, :format => 'html'
      end

      # Variables
      it "should have current employee" do
        subject.current_user.should_not be_nil
        subject.current_employee.should_not be_nil
      end

      # Response
      it { should_not assign_to(:employee) }
      it { should respond_with(:redirect) }
      it { should redirect_to(employee_home_path) }

      # Content
      it { should set_the_flash[:alert].to(/already signed in/) }
    end

    context "as authenticated customer" do
      include_context "with authenticated customer"
      before(:each) do
        @request.env["devise.mapping"] = Devise.mappings[:employee]
        employee = FactoryGirl.create(:employee)
        attributes = {:email => employee.email}
        post :create, :employee => attributes, :format => 'html'
      end

      # Variables
      it "should have current customer" do
        subject.current_user.should_not be_nil
        subject.current_employee.should be_nil
        subject.current_customer.should_not be_nil
      end

      # Response
      it { should_not assign_to(:employee) }
      it { should respond_with(:redirect) }
      it { should redirect_to(employee_scope_conflict_path) }

      # Content
      it { should_not set_the_flash }
    end

    context "as authenticated store" do
      include_context "with authenticated store"
      before(:each) do
        @request.env["devise.mapping"] = Devise.mappings[:employee]
        employee = FactoryGirl.create(:employee)
        attributes = {:email => employee.email}
        post :create, :employee => attributes, :format => 'html'
      end

      # Variables
      it "should have current store" do
        subject.current_user.should_not be_nil
        subject.current_employee.should be_nil
        subject.current_store.should_not be_nil
      end

      # Response
      it { should_not assign_to(:employee) }
      it { should respond_with(:redirect) }
      it { should redirect_to(employee_scope_conflict_path) }

      # Content
      it { should_not set_the_flash }
    end
  end

  describe "#show", :show => true do
    context "as unlocked employee" do
      include_context "with unauthenticated employee"
      
      describe "without token" do
        before(:each) do
          @request.env["devise.mapping"] = Devise.mappings[:employee]
          get :show, :format => 'html'
        end

        # Variables
        it "should not have current user" do
          subject.current_user.should be_nil
          subject.current_employee.should be_nil
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
          @request.env["devise.mapping"] = Devise.mappings[:employee]
          @request.env['QUERY_STRING'] = "unlock_token="
          get :show, :unlock_token => "1234234234", :format => 'html'
        end

        # Variables
        it "should have current user" do
          subject.current_user.should be_nil
          subject.current_employee.should be_nil
        end

        # Response
        it { should assign_to(:employee) }
        it { should respond_with(:success) }

        # Content
        it { should_not set_the_flash }
        it { should render_template(:new) }
      end
    end

    context "as locked employee" do
      include_context "with locked employee"
      
      describe "without token" do
        before(:each) do
          @request.env["devise.mapping"] = Devise.mappings[:employee]
          get :show, :format => 'html'
        end

        # Variables
        it "should not have current user" do
          subject.current_user.should be_nil
          subject.current_employee.should be_nil
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
          @request.env["devise.mapping"] = Devise.mappings[:employee]
          @request.env['QUERY_STRING'] = "unlock_token="
          get :show, :unlock_token => "1234234234", :format => 'html'
        end

        # Variables
        it "should have current user" do
          subject.current_user.should be_nil
          subject.current_employee.should be_nil
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
          @request.env["devise.mapping"] = Devise.mappings[:employee]
          @request.env['QUERY_STRING'] = "unlock_token="
          get :show, :unlock_token => "#{employee.unlock_token}", :format => 'html'
        end        

        # Variables
        it "should have current user" do
          subject.current_user.should be_nil
          subject.current_employee.should be_nil
        end

        # Response
        it { should assign_to(:employee) }
        it { should redirect_to(new_employee_session_path) }
  
        # Content
        it { should set_the_flash[:notice].to(/unlocked successfully. Please sign in/) }
      end
    end

    context "as authenticated employee" do
      include_context "with authenticated employee"
 
      before(:each) do
        @request.env["devise.mapping"] = Devise.mappings[:employee]
        @request.env['QUERY_STRING'] = "unlock_token="
        get :show, :unlock_token => "abcdef", :format => 'html'
      end        

      # Variables
      it "should have current employee" do
        subject.current_user.should_not be_nil
        subject.current_employee.should_not be_nil
      end

      # Response
      it { should_not assign_to(:employee) }
      it { should respond_with(:redirect) }
      it { should redirect_to(employee_home_path) }

      # Content
      it { should set_the_flash[:alert].to(/already signed in/) }
    end

    context "as authenticated customer" do
      include_context "with authenticated customer"
      before(:each) do
        @request.env["devise.mapping"] = Devise.mappings[:employee]
        @request.env['QUERY_STRING'] = "unlock_token="
        get :show, :unlock_token => "12341234", :format => 'html'
      end

      # Variables
      it "should have current customer" do
        subject.current_user.should_not be_nil
        subject.current_employee.should be_nil
        subject.current_customer.should_not be_nil
      end

      # Response
      it { should_not assign_to(:employee) }
      it { should respond_with(:redirect) }
      it { should redirect_to(employee_scope_conflict_path) }

      # Content
      it { should_not set_the_flash }
    end

    context "as authenticated store" do
      include_context "with authenticated store"
      before(:each) do
        @request.env["devise.mapping"] = Devise.mappings[:employee]
        @request.env['QUERY_STRING'] = "unlock_token="
        get :show, :unlock_token => "12341234", :format => 'html'
      end

      # Variables
      it "should have current store" do
        subject.current_user.should_not be_nil
        subject.current_employee.should be_nil
        subject.current_store.should_not be_nil
      end

      # Response
      it { should_not assign_to(:employee) }
      it { should respond_with(:redirect) }
      it { should redirect_to(employee_scope_conflict_path) }

      # Content
      it { should_not set_the_flash }
    end
  end
end