require 'spec_helper'

describe Employee::ConfirmationsController do
  # Controller Shared Methods
  #----------------------------------------------------------------------------
  def do_get_new
    @request.env["devise.mapping"] = Devise.mappings[:employee]
    get :new, :format => 'html'
  end

  def do_post_create(attributes)
    @request.env["devise.mapping"] = Devise.mappings[:employee]
    post :create, :employee => attributes, :format => 'html'
  end

  def do_get_show(token)
    @request.env["devise.mapping"] = Devise.mappings[:employee]
    @request.env['QUERY_STRING'] = "confirmation_token="
    get :show, :confirmation_token => token, :format => 'html'
  end

  # Routing
  #----------------------------------------------------------------------------
  describe "routing", :routing => true do
    it { should route(:get, "/employee/confirmation/new").to(:action => :new) }
    it { should route(:post, "/employee/confirmation").to(:action => :create) }
    it { should route(:get, "/employee/confirmation").to(:action => :show) }
  end

  # Methods
  #----------------------------------------------------------------------------
  describe "#new", :new => true do
    context "as unauthenticated employee" do
      include_context "with unauthenticated employee"
      
      before(:each) do
        do_get_new
      end

      # Variables
      it "should not have current user" do
        subject.current_user.should be_nil
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
        do_get_new
      end

      # Variables
      it "should not have current user" do
        subject.current_user.should_not be_nil
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
        do_get_new
      end

      # Variables
      it "should have current customer" do
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
        do_get_new
      end

      # Variables
      it "should have current store" do
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
    context "as unauthenticated employee" do
      include_context "with unauthenticated employee"

      context "with invalid email" do
        let(:attributes) { { :email => "fake@email.com" } }

        before(:each) do
          do_post_create(attributes)
        end

        # Parameters
#       it { should permit(:email).for(:create) }

        # Variables
        it "should not have current user" do
          subject.current_user.should be_nil
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

      context "with valid email" do
        let(:attributes) { { :email => employee.email } }

        before(:each) do
          do_post_create(attributes)
        end

        # Parameters
#       it { should permit(:email).for(:create) }

        # Variables
        it "should not have current user" do
          subject.current_user.should be_nil
        end
  
        # Response
        it { should assign_to(:employee) }
        it { should respond_with(:success) }

        # Content
        it { should render_template(:new) }

        # Behavior
        it "should not send email" do
          last_email.should be_nil
        end
      end
    end
    
    context "with unconfirmed employee" do
      include_context "with unconfirmed employee"

      context "with invalid email" do
        let(:attributes) { { :email => "fake@email.com" } }

        before(:each) do
          do_post_create(attributes)
        end

        # Parameters
#       it { should permit(:email).for(:create) }

        # Variables
        it "should not have current user" do
          subject.current_user.should be_nil
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

      context "with valid email" do
        let(:attributes) { { :email => employee.email } }

        before(:each) do
          do_post_create(attributes)
        end

        # Parameters
#       it { should permit(:email).for(:create) }

        # Variables
        it "should not have current user" do
          subject.current_user.should be_nil
        end

        # Response
        it { should assign_to(:employee) }
        it { should respond_with(:redirect) }
        it { should redirect_to(home_path) }

        # Content
        it { should set_the_flash[:notice].to(/email with instructions about how to confirm/) }

        # Behavior
        it "should send confirmation email" do
          last_email.should_not be_nil
          last_email.to.should eq([employee.email])
          last_email.body.should match(/#{employee.confirmation_token}/)
        end
      end
    end

    context "as authenticated employee" do
      include_context "with authenticated employee"

      context "with invalid email" do
        let(:attributes) { { :email => "fake@email.com" } }

        before(:each) do
          do_post_create(attributes)
        end

        # Parameters
#       it { should permit(:email).for(:create) }

        # Variables
        it "should have current employee" do
          subject.current_employee.should_not be_nil
        end

        # Response
        it { should_not assign_to(:employee) }
        it { should respond_with(:redirect) }
        it { should redirect_to(employee_home_path) }

        # Content
        it { should set_the_flash[:alert].to(/already signed in/) }

        # Behavior
        it "should not send confirmation email" do
          last_email.should be_nil
        end
      end

      context "with valid email" do
        let(:attributes) { { :email => employee.email } }

        before(:each) do
          do_post_create(attributes)
        end
  
        # Parameters
  #       it { should permit(:email).for(:create) }
  
        # Variables
        it "should have current employee" do
          subject.current_employee.should_not be_nil
        end

        # Response
        it { should_not assign_to(:employee) }
        it { should respond_with(:redirect) }
        it { should redirect_to(employee_home_path) }
  
        # Content
        it { should set_the_flash[:alert].to(/already signed in/) }
      end
    end

    context "as authenticated customer" do
      include_context "with authenticated customer"
      let(:employee) { FactoryGirl.create(:employee) }
      let(:attributes) { { :email => employee.email } }

      before(:each) do
        do_post_create(attributes)
      end

      # Variables
      it "should have current customer" do
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
      let(:employee) { FactoryGirl.create(:employee) }
      let(:attributes) { { :email => employee.email } }

      before(:each) do
        do_post_create(attributes)
      end

      # Variables
      it "should have current store" do
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
    context "as unconfirmed employee" do
      include_context "with unconfirmed employee"
      
      context "with invalid token" do
        before(:each) do
          do_get_show("12341234123")
        end

        # Variables
        it "should not have current user" do
          subject.current_user.should be_nil
        end

        # Response
        it { should assign_to(:employee) }
        it { should respond_with(:success) }

        # Content
        it { should_not set_the_flash }
        it { should render_template(:new) }
      end

      context "with valid token" do
        before(:each) do
          do_get_show(employee.confirmation_token)
        end        

        # Variables
        it "should have current employee" do
          subject.current_employee.should_not be_nil
        end

        # Response
        it { should assign_to(:employee) }
        it { should redirect_to(employee_home_path) }
  
        # Content
        it { should set_the_flash[:notice].to(/successfully confirmed/) }
      end
    end
    
    context "as authenticated employee" do
      include_context "with authenticated employee"

      context "with valid token" do
        before(:each) do
          do_get_show(employee.confirmation_token)
        end        

        # Variables
        it "should have current employee" do
          subject.current_employee.should_not be_nil
        end

        # Response
        it { should_not assign_to(:employee) }
        it { should redirect_to(employee_home_path) }
  
        # Content
        it { should set_the_flash[:alert].to(/already signed in/) }
      end
    end

    context "as authenticated store" do
      include_context "with authenticated store"
      let(:employee) { FactoryGirl.create(:employee) }

      before(:each) do
        do_get_show(employee.confirmation_token)
      end

      # Variables
      it "should have current store" do
        subject.current_store.should_not be_nil
      end

      # Response
      it { should_not assign_to(:employee) }
      it { should respond_with(:redirect) }
      it { should redirect_to(employee_scope_conflict_path) }

      # Content
      it { should_not set_the_flash }
    end

    context "as authenticated customer" do
      include_context "with authenticated customer"
      let(:employee) { FactoryGirl.create(:employee) }

      before(:each) do
        do_get_show(customer.confirmation_token)
      end

      # Variables
      it "should have current customer" do
        subject.current_customer.should_not be_nil
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