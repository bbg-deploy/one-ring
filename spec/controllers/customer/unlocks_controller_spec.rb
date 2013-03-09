require 'spec_helper'

describe Customer::UnlocksController do
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

  def do_get_show(unlock_token)
    @request.env["devise.mapping"] = Devise.mappings[:customer]
    @request.env['QUERY_STRING'] = "unlock_token="
    get :show, :unlock_token => unlock_token, :format => 'html'
  end

  # Routing
  #----------------------------------------------------------------------------
  describe "routing", :routing => true do
    it { should route(:get, "/customer/unlock/new").to(:action => :new) }
    it { should route(:post, "/customer/unlock").to(:action => :create) }
    it { should route(:get, "/customer/unlock").to(:action => :show) }
  end

  # Public Methods
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
        subject.current_customer.should be_nil
      end

      # Response
      it { should assign_to(:customer) }
      it { should respond_with(:success) }

      # Content
      it { should_not set_the_flash }
      it { should render_template(:new) }
    end

    context "as authenticated customer" do
      include_context "with authenticated customer"
 
      before(:each) do
        do_get_new
      end

      # Variables
      it "should have current customer" do
        subject.current_user.should_not be_nil
        subject.current_customer.should_not be_nil
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
        subject.current_user.should_not be_nil
        subject.current_customer.should be_nil
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
        subject.current_user.should_not be_nil
        subject.current_customer.should be_nil
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
    context "as unlocked customer" do
      include_context "with unauthenticated customer"
      let(:attributes) { { :email => customer.email } }

      before(:each) do
        do_post_create(attributes)
      end

      # Parameters
#       it { should permit(:email).for(:create) }

      # Variables
      it "should not have current user" do
        subject.current_user.should be_nil
        subject.current_customer.should be_nil
      end

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

    context "as locked customer" do
      include_context "with locked customer"

      context "with invalid email" do
        let(:attributes) { { :email => "mismatch@email.com" } }
        before(:each) do
          do_post_create(attributes)
        end
  
        # Parameters
  #       it { should permit(:email).for(:create) }
  
        # Variables
        it "should not have current user" do
          subject.current_user.should be_nil
          subject.current_customer.should be_nil
        end

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
          subject.current_customer.should be_nil
        end

        # Response
        it { should assign_to(:customer) }
        it { should respond_with(:redirect) }
        it { should redirect_to(new_customer_session_path) }
  
        # Content
        it { should set_the_flash[:notice].to(/email with instructions about how to unlock/) }

        # Behavior
        it "should send confirmation email to customer" do
          last_email.should_not be_nil
          last_email.to.should eq([customer.email])
        end
      end
    end

    context "as authenticated customer" do
      include_context "with authenticated customer"
      let(:attributes) { { :email => customer.email } }
 
      before(:each) do
        do_post_create(attributes)
      end

      # Variables
      it "should have current customer" do
        subject.current_user.should_not be_nil
        subject.current_customer.should_not be_nil
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
      let(:customer) { FactoryGirl.create(:confirmed_customer) }
      let(:attributes) { { :email => customer.email } }
 
      before(:each) do
        do_post_create(attributes)
      end

      # Variables
      it "should have current store" do
        subject.current_user.should_not be_nil
        subject.current_customer.should be_nil
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
      let(:customer) { FactoryGirl.create(:confirmed_customer) }
      let(:attributes) { { :email => customer.email } }
 
      before(:each) do
        do_post_create(attributes)
      end

      # Variables
      it "should have current employee" do
        subject.current_user.should_not be_nil
        subject.current_customer.should be_nil
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
    context "as unlocked customer" do
      include_context "with unauthenticated customer"
      
      context "without token" do
        before(:each) do
          do_get_show(nil)
        end

        # Variables
        it "should not have current user" do
          subject.current_user.should be_nil
          subject.current_customer.should be_nil
        end
  
        # Response
        it { should assign_to(:customer) }
        it { should respond_with(:success) }

        # Content
        it { should_not set_the_flash }
        it { should render_template(:new) }
      end

      context "with invalid token" do
        before(:each) do
          do_get_show("1234234234")
        end

        # Variables
        it "should have current user" do
          subject.current_user.should be_nil
          subject.current_customer.should be_nil
        end

        # Response
        it { should assign_to(:customer) }
        it { should respond_with(:success) }

        # Content
        it { should_not set_the_flash }
        it { should render_template(:new) }
      end
    end

    context "as locked customer" do
      include_context "with locked customer"
      
      context "without token" do
        before(:each) do
          do_get_show(nil)
        end

        # Variables
        it "should not have current user" do
          subject.current_user.should be_nil
          subject.current_customer.should be_nil
        end
  
        # Response
        it { should assign_to(:customer) }
        it { should respond_with(:success) }

        # Content
        it { should_not set_the_flash }
        it { should render_template(:new) }
      end

      context "with invalid token" do
        before(:each) do
          do_get_show("1234234234")
        end

        # Variables
        it "should have current user" do
          subject.current_user.should be_nil
          subject.current_customer.should be_nil
        end

        # Response
        it { should assign_to(:customer) }
        it { should respond_with(:success) }

        # Content
        it { should_not set_the_flash }
        it { should render_template(:new) }
      end

      context "with valid token" do
        before(:each) do
          do_get_show("#{customer.unlock_token}")
        end        

        # Variables
        it "should have current user" do
          subject.current_user.should be_nil
          subject.current_customer.should be_nil
        end

        # Response
        it { should assign_to(:customer) }
        it { should redirect_to(new_customer_session_path) }
  
        # Content
        it { should set_the_flash[:notice].to(/unlocked successfully. Please sign in/) }
      end
    end

    context "as authenticated customer" do
      include_context "with authenticated customer"
 
      before(:each) do
        do_get_show("12341234234")
      end        

      # Variables
      it "should have current customer" do
        subject.current_user.should_not be_nil
        subject.current_customer.should_not be_nil
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
        do_get_show("1234234234")
      end

      # Variables
      it "should have current store" do
        subject.current_user.should_not be_nil
        subject.current_customer.should be_nil
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
        do_get_show("1234234234")
      end

      # Variables
      it "should have current employee" do
        subject.current_user.should_not be_nil
        subject.current_customer.should be_nil
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