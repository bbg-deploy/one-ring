require 'spec_helper'

describe Customer::ConfirmationsController do
  # Controller Shared Methods
  #----------------------------------------------------------------------------
  def do_get_new
    @request.env["devise.mapping"] = Devise.mappings[:customer]
    get :new, :format => 'html'
  end

  def do_post_create(attributes)
    @request.env["devise.mapping"] = Devise.mappings[:customer]
    post :create, :customer => attributes, :format => 'html'
  end

  def do_get_show(token)
    @request.env["devise.mapping"] = Devise.mappings[:customer]
    @request.env['QUERY_STRING'] = "confirmation_token="
    get :show, :confirmation_token => token, :format => 'html'
  end

  # Routing
  #----------------------------------------------------------------------------
  describe "routing", :routing => true do
    it { should route(:get, "/customer/confirmation/new").to(:action => :new) }
    it { should route(:post, "/customer/confirmation").to(:action => :create) }
    it { should route(:get, "/customer/confirmation").to(:action => :show) }
  end

  # Methods
  #----------------------------------------------------------------------------
  describe "#new", :new => true do
    context "as unauthenticated customer" do
      include_context "with unauthenticated customer"
      
      before(:each) do
        do_get_new
      end

      # Variables
      it "should not have current user" do
        subject.current_user.should be_nil
      end

      # Response
      it { should assign_to(:customer) }
      it { should respond_with(:success) }

      # Content
      it { should_not set_the_flash }
      it { should render_template(:new) }
      it { should render_template("layouts/application") }
    end

    context "as authenticated customer" do
      include_context "with authenticated customer"

      before(:each) do
        do_get_new
      end

      # Variables
      it "should not have current user" do
        subject.current_user.should_not be_nil
      end

      # Response
      it { should_not assign_to(:customer) }
      it { should respond_with(:redirect) }
      it { should redirect_to(customer_home_path) }

      # Content
      it { should set_the_flash[:alert].to(/already signed in/) }
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
      it { should_not assign_to(:customer) }
      it { should respond_with(:redirect) }
      it { should redirect_to(customer_scope_conflict_path) }

      # Content
      it { should_not set_the_flash }
    end

    context "as authenticated employee" do
      include_context "with authenticated employee"

      before(:each) do
        do_get_new
      end

      # Variables
      it "should have current employee" do
        subject.current_employee.should_not be_nil
      end

      # Response
      it { should_not assign_to(:customer) }
      it { should respond_with(:redirect) }
      it { should redirect_to(customer_scope_conflict_path) }

      # Content
      it { should_not set_the_flash }
    end
  end

  describe "#create", :create => true do
    context "as unauthenticated customer" do
      include_context "with unauthenticated customer"

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
        it { should assign_to(:customer) }
        it { should respond_with(:success) }

        # Content
        it { should_not set_the_flash }
        it { should render_template(:new) }
        it { should render_template("layouts/application") }

        # Behavior
        it "should not send confirmation email" do
          last_email.should be_nil
        end
      end

      context "with valid email" do
        let(:attributes) { { :email => customer.email } }

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
        it { should assign_to(:customer) }
        it { should respond_with(:success) }
        it { should render_template("layouts/application") }

        # Content
        it { should render_template(:new) }

        # Behavior
        it "should not send email" do
          last_email.should be_nil
        end
      end
    end
    
    context "with unconfirmed customer" do
      include_context "with unconfirmed customer"

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
        it { should assign_to(:customer) }
        it { should respond_with(:success) }
        it { should render_template("layouts/application") }

        # Content
        it { should_not set_the_flash }
        it { should render_template(:new) }

        # Behavior
        it "should not send confirmation email" do
          last_email.should be_nil
        end
      end

      context "with valid email" do
        let(:attributes) { { :email => customer.email } }

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
        it { should assign_to(:customer) }
        it { should respond_with(:redirect) }
        it { should redirect_to(home_path) }

        # Content
        it { should set_the_flash[:notice].to(/email with instructions about how to confirm/) }

        # Behavior
        it "should send confirmation email" do
          last_email.should_not be_nil
          last_email.to.should eq([customer.email])
          last_email.body.should match(/#{customer.confirmation_token}/)
        end
        it { should render_template("customer_authentication_mailer/confirmation_instructions")}
      end
    end

    context "as authenticated customer" do
      include_context "with authenticated customer"

      context "with invalid email" do
        let(:attributes) { { :email => "fake@email.com" } }

        before(:each) do
          do_post_create(attributes)
        end

        # Parameters
#       it { should permit(:email).for(:create) }

        # Variables
        it "should have current customer" do
          subject.current_customer.should_not be_nil
        end

        # Response
        it { should_not assign_to(:customer) }
        it { should respond_with(:redirect) }
        it { should redirect_to(customer_home_path) }

        # Content
        it { should set_the_flash[:alert].to(/already signed in/) }

        # Behavior
        it "should not send confirmation email" do
          last_email.should be_nil
        end
      end

      context "with valid email" do
        let(:attributes) { { :email => customer.email } }

        before(:each) do
          do_post_create(attributes)
        end
  
        # Parameters
  #       it { should permit(:email).for(:create) }
  
        # Variables
        it "should have current customer" do
          subject.current_customer.should_not be_nil
        end

        # Response
        it { should_not assign_to(:customer) }
        it { should respond_with(:redirect) }
        it { should redirect_to(customer_home_path) }
  
        # Content
        it { should set_the_flash[:alert].to(/already signed in/) }
      end
    end

    context "as authenticated store" do
      include_context "with authenticated store"
      let(:customer) { FactoryGirl.create(:customer) }
      let(:attributes) { { :email => customer.email } }

      before(:each) do
        do_post_create(attributes)
      end

      # Variables
      it "should have current store" do
        subject.current_store.should_not be_nil
      end

      # Response
      it { should_not assign_to(:customer) }
      it { should respond_with(:redirect) }
      it { should redirect_to(customer_scope_conflict_path) }

      # Content
      it { should_not set_the_flash }
    end

    context "as authenticated employee" do
      include_context "with authenticated employee"
      let(:customer) { FactoryGirl.create(:customer) }
      let(:attributes) { { :email => customer.email } }

      before(:each) do
        do_post_create(attributes)
      end

      # Variables
      it "should have current employee" do
        subject.current_employee.should_not be_nil
      end

      # Response
      it { should_not assign_to(:customer) }
      it { should respond_with(:redirect) }
      it { should redirect_to(customer_scope_conflict_path) }

      # Content
      it { should_not set_the_flash }
    end
  end

  describe "#show", :show => true do
    context "as unconfirmed customer" do
      include_context "with unconfirmed customer"
      
      context "with invalid token" do
        before(:each) do
          do_get_show("12341234123")
        end

        # Variables
        it "should not have current user" do
          subject.current_user.should be_nil
        end

        # Response
        it { should assign_to(:customer) }
        it { should respond_with(:success) }

        # Content
        it { should_not set_the_flash }
        it { should render_template(:new) }
        it { should render_template("layouts/application") }
      end

      context "with valid token" do
        before(:each) do
          do_get_show(customer.confirmation_token)
        end        

        # Variables
        it "should have current customer" do
          subject.current_customer.should_not be_nil
        end

        # Response
        it { should assign_to(:customer) }
        it { should redirect_to(customer_home_path) }
  
        # Content
        it { should set_the_flash[:notice].to(/successfully confirmed/) }
      end
    end
    
    context "as authenticated customer" do
      include_context "with authenticated customer"

      context "with valid token" do
        before(:each) do
          do_get_show(customer.confirmation_token)
        end        

        # Variables
        it "should have current customer" do
          subject.current_customer.should_not be_nil
        end

        # Response
        it { should_not assign_to(:customer) }
        it { should redirect_to(customer_home_path) }
  
        # Content
        it { should set_the_flash[:alert].to(/already signed in/) }
      end
    end

    context "as authenticated store" do
      include_context "with authenticated store"
      let(:customer) { FactoryGirl.create(:customer) }

      before(:each) do
        do_get_show(customer.confirmation_token)
      end

      # Variables
      it "should have current store" do
        subject.current_store.should_not be_nil
      end

      # Response
      it { should_not assign_to(:customer) }
      it { should respond_with(:redirect) }
      it { should redirect_to(customer_scope_conflict_path) }

      # Content
      it { should_not set_the_flash }
    end

    context "as authenticated employee" do
      include_context "with authenticated employee"
      let(:customer) { FactoryGirl.create(:customer) }

      before(:each) do
        do_get_show(customer.confirmation_token)
      end

      # Variables
      it "should have current employee" do
        subject.current_employee.should_not be_nil
      end

      # Response
      it { should_not assign_to(:customer) }
      it { should respond_with(:redirect) }
      it { should redirect_to(customer_scope_conflict_path) }

      # Content
      it { should_not set_the_flash }
    end
  end
end