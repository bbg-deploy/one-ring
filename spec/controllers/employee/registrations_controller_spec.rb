require 'spec_helper'

describe Employee::RegistrationsController do
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

  def do_get_edit
    @request.env["devise.mapping"] = Devise.mappings[:employee]
    get :edit, :format => 'html'
  end

  def do_put_update(attributes)
    @request.env["devise.mapping"] = Devise.mappings[:employee]
    put :update, :employee => attributes, :format => 'html'
  end

  def do_delete_destroy
    @request.env["devise.mapping"] = Devise.mappings[:employee]
    delete :destroy, :format => 'html'
  end

  def do_get_cancel
    @request.env["devise.mapping"] = Devise.mappings[:employee]
    get :cancel, :format => 'html'
  end

  # Routing
  #----------------------------------------------------------------------------
  describe "routing", :routing => true do
    it { should route(:get, "/employee/sign_up").to(:action => :new) }
    it { should route(:post, "/employee").to(:action => :create) }
    it { should route(:get, "/employee/edit").to(:action => :edit) }
    it { should route(:put, "/employee").to(:action => :update) }
    it { should route(:delete, "/employee").to(:action => :destroy) }
    it { should route(:get, "/employee/cancel").to(:action => :cancel) }
  end

  # Public Methods
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
      it "should have current employee" do
        subject.current_employee.should_not be_nil
      end

      # Response
      it { should_not assign_to(:employee) }
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

      context "with valid attributes" do
        let(:attributes) { FactoryGirl.build(:employee_attributes_hash) }
        before(:each) do
          do_post_create(attributes)
        end

#       it { should permit(:username, :email, :email_confirmation, :password, :password_confirmation).for(:create) }
#       it { should permit(:first_name, :middle_name, :last_name, :date_of_birth, :social_security_number).for(:create) }
#       it { should permit(:mailing_address_attributes, :phone_number_attributes).for(:create) }

        # Variables
        it "should not have current user" do
          subject.current_user.should be_nil
        end

        # Response
        it { should assign_to(:employee) }
        it { should respond_with(:redirect) }
        it { should redirect_to(home_path) }

        # Content
        it { should set_the_flash[:notice].to(/message with a confirmation link/) }

        # Behavior
        it "creates a new employee" do
          Employee.last.try(:email).should eq(attributes[:email])
        end

        it "sends confirmation email" do
          confirmation_email_sent_to?(attributes[:email]).should be_true
        end
      end

      context "with invalid attributes" do
        let(:attributes) { FactoryGirl.build(:employee_attributes_hash, :username => nil) }
        before(:each) do
          do_post_create(attributes)
        end

        # Variables
        it "should not have current user" do
          subject.current_user.should be_nil
        end

        # Response
        it { should assign_to(:employee) }
        it { should respond_with(:success) }
        it { should render_template(:new) }

        # Content
        it { should set_the_flash[:alert].to(/was a problem/) }

        # Behavior
        it "does not creates a new employee" do
            Employee.last.try(:email).should_not eq(attributes[:email])
        end
  
        it "does not send confirmation email" do
          confirmation_email_sent_to?(attributes[:email]).should be_false
        end
      end
    end    

    context "as authenticated employee" do
      include_context "with authenticated employee"

      let(:attributes) { FactoryGirl.build(:employee_attributes_hash) }
      before(:each) do
        do_post_create(attributes)
      end

      # Variables
      it "should have current user" do
        subject.current_user.should_not be_nil
      end

      # Response
      it { should_not assign_to(:employee) }
      it { should redirect_to(employee_home_path) }

      # Content
      it { should set_the_flash[:alert].to(/already signed in/) }
    end

    context "as authenticated customer" do
      include_context "with authenticated customer"
      let(:attributes) { FactoryGirl.build(:employee_attributes_hash) }
      
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
      let(:attributes) { FactoryGirl.build(:employee_attributes_hash) }

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

  describe "#edit", :edit => true do
    context "as unauthenticated employee" do
      include_context "with unauthenticated employee"
      before(:each) do
        do_get_edit
      end

      # Variables
      it "should not have current user" do
        subject.current_user.should be_nil
      end

      # Response
      it { should_not assign_to(:employee) }
      it { should redirect_to(new_employee_session_path) }

      # Content
      it { should set_the_flash[:alert].to(/need to sign in or sign up/) }
    end

    context "as authenticated employee" do
      include_context "with authenticated employee"
      before(:each) do
        do_get_edit
      end

      # Variables
      it "should have current employee" do
        subject.current_employee.should_not be_nil
      end

      # Response
      it { should assign_to(:employee) }
      it { should respond_with(:success) }

      # Content
      it { should_not set_the_flash }
      it { should render_template(:edit) }
    end    

    context "as authenticated customer" do
      include_context "with authenticated customer"
      before(:each) do
        do_get_edit
      end

      # Variables
      it "should have current customer" do
        subject.current_customer.should_not be_nil
      end

      # Response
      it { should_not assign_to(:employee) }
      it { should respond_with(:redirect) }
      it { should redirect_to(new_employee_session_path) }

      # Content
      it { should set_the_flash[:alert].to(/need to sign in or sign up/) }
    end

    context "as authenticated store" do
      include_context "with authenticated store"
      before(:each) do
        do_get_edit
      end

      # Variables
      it "should have current store" do
        subject.current_store.should_not be_nil
      end

      # Response
      it { should_not assign_to(:employee) }
      it { should respond_with(:redirect) }
      it { should redirect_to(new_employee_session_path) }

      # Content
      it { should set_the_flash[:alert].to(/need to sign in or sign up/) }
    end
  end

  describe "#update", :update => true do
    context "as unauthenticated employee" do
      include_context "with unauthenticated employee"
      let(:attributes) { FactoryGirl.build(:employee_attributes_hash) }

      before(:each) do
        do_put_update(attributes)
      end

      # Variables
      it "should not have current user" do
        subject.current_user.should be_nil
      end

      # Response
      it { should_not assign_to(:employee) }
      it { should redirect_to(new_employee_session_path) }

      # Content
      it { should set_the_flash[:alert].to(/need to sign in or sign up/) }
    end
    
    context "as authenticated employee" do
      include_context "with authenticated employee"

      context "with valid attributes (name)", :failing => true do
        let(:attributes) { { :first_name => "Clark", :last_name => "Kent", :current_password => employee.password } }

        before(:each) do
          do_put_update(attributes)
        end
        
        it "should have current employee" do
          subject.current_employee.should_not be_nil
        end

        # Response
        it { should assign_to(:employee) }
        it { should redirect_to(employee_home_path) }
  
        # Content
        it { should set_the_flash[:notice].to(/updated your account successfully/) }

        # Behavior
        it "should change name" do
          employee.reload
          employee.first_name.should eq("Clark")
          employee.last_name.should eq("Kent")
        end

        it "should not send confirmation email" do
          confirmation_email_sent_to?(employee.email).should be_false
        end
      end

      context "with valid attributes (password)" do
        let(:attributes) { { :password => "newpass", :password_confirmation => "newpass", :current_password => employee.password } }

        before(:each) do
          do_put_update(attributes)
        end
        
        it "should have current employee" do
          subject.current_employee.should_not be_nil
        end

        # Response
        it { should assign_to(:employee) }
        it { should redirect_to(employee_home_path) }
  
        # Content
        it { should set_the_flash[:notice].to(/updated your account successfully/) }

        # Behavior
        it "should change password" do
          old_password = employee.encrypted_password
          employee.reload
          employee.encrypted_password.should_not eq(old_password)
        end

        it "should not send confirmation email" do
          confirmation_email_sent_to?(employee.email).should be_false
        end
      end

      context "with valid attributes (new email address)" do
        let(:attributes) { { :email => "new@credda.com", :email_confirmation => "new@credda.com", :current_password => employee.password } }

        before(:each) do
          do_put_update(attributes)
        end

        it "should have current employee" do
          subject.current_employee.should_not be_nil
        end

        # Response
        it { should assign_to(:employee) }
        it { should redirect_to(employee_home_path) }
  
        # Content
        it { should set_the_flash[:notice].to(/updated your account successfully/) }

        # Behavior
        it "should change email" do
          employee.reload
          employee.unconfirmed_email.should eq(attributes[:email])
        end

        it "should send confirmation email to new address" do
          confirmation_email_sent_to?(employee.email).should be_false
          confirmation_email_sent_to?(attributes[:email]).should be_true
        end            
      end

      context "with invalid attributes (no current password)" do
        let(:attributes) { { :first_name => "Clark", :last_name => "Kent" } }

        before(:each) do
          do_put_update(attributes)
        end
        
        it "should have current employee" do
          subject.current_employee.should_not be_nil
        end

        # Response
        it { should assign_to(:employee) }
        it { should respond_with(:success) }
        it { should render_template(:edit) }
  
        # Content
        it { should set_the_flash[:alert].to(/problem with some of your information/) }

        # Behavior
        it "should not change name" do
          employee.reload
          employee.first_name.should_not eq("Clark")
          employee.last_name.should_not eq("Kent")
        end

        it "should not send confirmation email" do
          confirmation_email_sent_to?(employee.email).should be_false
        end
      end

      context "with invalid attributes (email confirmation mismatch)" do
        let(:attributes) { { :email => "new@email.com", :email_confirmation => "mismatch@email.com", :current_password => employee.password } }

        before(:each) do
          do_put_update(attributes)
        end
        
        it "should have current employee" do
          subject.current_employee.should_not be_nil
        end

        # Response
        it { should assign_to(:employee) }
        it { should respond_with(:success) }
        it { should render_template(:edit) }
  
        # Content
        it { should set_the_flash[:alert].to(/problem with some of your information/) }

        # Behavior
        it "should not change name" do
          employee.reload
          employee.first_name.should_not eq("Clark")
          employee.last_name.should_not eq("Kent")
        end

        it "should not send confirmation email" do
          confirmation_email_sent_to?(employee.email).should be_false
        end
      end
    end

    context "as authenticated customer" do
      include_context "with authenticated customer"
      let(:attributes) { FactoryGirl.build(:employee_attributes_hash) }
      
      before(:each) do
        do_put_update(attributes)
      end

      # Variables
      it "should have current customer" do
        subject.current_customer.should_not be_nil
      end

      # Response
      it { should_not assign_to(:employee) }
      it { should respond_with(:redirect) }
      it { should redirect_to(new_employee_session_path) }

      # Content
      it { should set_the_flash[:alert].to(/need to sign in or sign up/) }
    end

    context "as authenticated store" do
      include_context "with authenticated store"
      let(:attributes) { FactoryGirl.build(:employee_attributes_hash) }

      before(:each) do
        do_put_update(attributes)
      end

      # Variables
      it "should have current store" do
        subject.current_store.should_not be_nil
      end

      # Response
      it { should_not assign_to(:employee) }
      it { should respond_with(:redirect) }
      it { should redirect_to(new_employee_session_path) }

      # Content
      it { should set_the_flash[:alert].to(/need to sign in or sign up/) }
    end
  end

  describe "#destroy", :destroy => true do
    context "as unauthenticated customer" do
      include_context "with unauthenticated customer"

      before(:each) do
        do_delete_destroy
      end

      # Variables
      it "should not have current user" do
        subject.current_user.should be_nil
        subject.current_customer.should be_nil
      end

      # Response
      it { should_not assign_to(:customer) }
      it { should redirect_to(new_customer_session_path) }

      # Content
      it { should set_the_flash[:alert].to(/need to sign in or sign up/) }
    end
    
    context "as authenticated customer" do
      include_context "with authenticated customer"
      
      before(:each) do
        do_delete_destroy
      end

      # Variables
      it "should not have current customer (logged out)" do
        subject.current_user.should be_nil
        subject.current_customer.should be_nil
      end

      # Response
      it { should assign_to(:customer) }
      it { should redirect_to(home_path) }

      # Content
      it { should set_the_flash[:notice].to(/account was successfully cancelled/) }

      # External Requests
      it "does not request Authorize.net" do
        a_request(:post, /https:\/\/apitest.authorize.net\/xml\/v1\/request.api.*/).with(:body => /.*createCustomerProfileRequest.*/).should_not have_been_made
      end

      # Behavior
      it "should be 'cancelled'" do
        customer.reload
        customer.cancelled?.should be_true
      end

      it "should still persist in database" do
        customer.reload
        customer.should be_valid
      end
    end

    context "as authenticated store" do
      include_context "with authenticated store"
      before(:each) do
        do_delete_destroy
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
      it { should redirect_to(new_customer_session_path) }

      # Content
      it { should set_the_flash[:alert].to(/need to sign in or sign up/) }
    end

    context "as authenticated employee" do
      include_context "with authenticated employee"
      before(:each) do
        do_delete_destroy
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
      it { should redirect_to(new_customer_session_path) }

      # Content
      it { should set_the_flash[:alert].to(/need to sign in or sign up/) }
    end
  end

  describe "#cancel", :cancel => true do
    context "as unauthenticated customer" do
      include_context "with unauthenticated customer"

      before(:each) do
        do_get_cancel
      end

      # Variables
      it "should not have current user" do
        subject.current_user.should be_nil
        subject.current_customer.should be_nil
      end

      # Response
      it { should_not assign_to(:customer) }
      it { should redirect_to(new_customer_registration_path) }

      # Content
      it { should_not set_the_flash }
    end
    
    context "as authenticated customer" do
      include_context "with authenticated customer"

      before(:each) do
        do_get_cancel
      end

      # Variables
      it "should have current customer" do
        subject.current_user.should_not be_nil
        subject.current_customer.should_not be_nil
      end

      # Response
      it { should_not assign_to(:customer) }
      it { should redirect_to(customer_home_path) }

      # Content
      it { should set_the_flash[:alert].to(/already signed in/) }
    end

    context "as authenticated store" do
      include_context "with authenticated store"

      before(:each) do
        do_get_cancel
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
        do_get_cancel
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