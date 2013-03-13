require 'spec_helper'

describe Customer::SessionsController do
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

  def do_delete_destroy
    @request.env["devise.mapping"] = Devise.mappings[:customer]
    delete :destroy, :format => 'html'
  end

  def do_get_scope_conflict
    @request.env["HTTP_REFERER"] = "/customer/edit"
    @request.env["devise.mapping"] = Devise.mappings[:customer]
    get :scope_conflict, :format => 'html'
  end

  def do_delete_resolve_conflict
    @request.env["devise.mapping"] = Devise.mappings[:customer]
    delete :resolve_conflict, :format => 'html'
  end

  # Routing
  #----------------------------------------------------------------------------
  describe "routing", :routing => true do
    it { should route(:get, "/customer/sign_in").to(:action => :new) }
    it { should route(:post, "/customer/sign_in").to(:action => :create) }
    it { should route(:delete, "/customer/sign_out").to(:action => :destroy) }
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
      end

      # Response
      it { should assign_to(:customer) }
      it { should respond_with(:success) }

      # Content
      it { should_not set_the_flash }
      it { should render_template("layouts/application") }
      it { should render_template(:new) }
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

      context "with invalid attributes" do
        let(:attributes) { { :login => customer.email, :password => "wrongpass" } }

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
        it { should_not assign_to(:customer) }
        it { should respond_with(:success) }
  
        # Content
        it { should_not set_the_flash }
        it { should render_template("layouts/application") }
        it { should render_template(:new) }

        # Behavior
        it "should increment failed attempts count" do
          customer.reload
          customer.failed_attempts.should eq(1)
        end
      end

      context "with too many failed logins" do
        let(:attributes) { { :login => customer.email, :password => "wrongpass#{Random.new.rand(100)}" } }

        before(:each) do
          customer.failed_attempts = 5
          customer.save
          do_post_create(attributes)
        end

        # Variables
        it "should not have current user" do
          subject.current_user.should be_nil
        end

        # Response
        it { should_not assign_to(:customer) }
        it { should respond_with(:success) }
  
        # Content
        it { should_not set_the_flash }
        it { should render_template("layouts/application") }
        it { should render_template(:new) }
        it "has locked message in alert" do
          flash = response.request.env["rack.session"]["flash"]
          flash.alert.should match(/account is locked/)
        end
      end

      context "with valid login (email)" do
        let(:attributes) { { :login => customer.email, :password => customer.password } }

        before(:each) do
          do_post_create(attributes)
        end

        # Variables
        it "should have current customer" do
          subject.current_customer.should_not be_nil
        end

        # Response
        it { should assign_to(:customer) }
        it { should respond_with(:redirect) }
        it { should redirect_to(customer_home_path) }
  
        # Content
        it { should set_the_flash[:notice].to(/Signed in successfully/) }
      end

      context "with valid login (username)" do
        let(:attributes) { { :login => customer.username, :password => customer.password } }

        context "without referrer or pre_conflict_path" do

          before(:each) do
            do_post_create(attributes)
          end
  
          # Variables
          it "should have current customer" do
            subject.current_customer.should_not be_nil
          end
  
          # Response
          it { should assign_to(:customer) }
          it { should respond_with(:redirect) }
          it { should redirect_to(customer_home_path) }
    
          # Content
          it { should set_the_flash[:notice].to(/Signed in successfully/) }
        end
        
        context "with referer" do

          before(:each) do
            session[:post_auth_path] = "/customer/edit"
            do_post_create(attributes)
          end
  
          # Variables
          it "should have current customer" do
            subject.current_customer.should_not be_nil
          end
  
          # Response
          it { should assign_to(:customer) }
          it { should respond_with(:redirect) }
          it { should redirect_to(edit_customer_registration_path) }
    
          # Content
          it { should set_the_flash[:notice].to(/Signed in successfully/) }
        end
        
        context "with referer and pre_conflict_path" do

          before(:each) do
            session[:post_auth_path] = "/customer"
            session[:pre_conflict_path] = "/customer/edit"
            do_post_create(attributes)
          end
  
          # Variables
          it "should have current customer" do
            subject.current_customer.should_not be_nil
          end
  
          # Response
          it { should assign_to(:customer) }
          it { should respond_with(:redirect) }
          it { should redirect_to(edit_customer_registration_path) }
    
          # Content
          it { should set_the_flash[:notice].to(/Signed in successfully/) }
        end
      end
    end
          
    context "as unconfirmed customer" do
      include_context "with unconfirmed customer"

      context "with valid login" do
        let(:attributes) { { :login => customer.email, :password => customer.password } }

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
        it { should_not assign_to(:customer) }
        it { should respond_with(:redirect) }
        it { should redirect_to(new_customer_session_path) }
  
        # Content
        it { should set_the_flash[:alert].to(/confirm your account before continuing/) }
      end
    end

    context "as locked customer" do
      include_context "with locked customer"

      context "with valid login" do
        let(:attributes) { { :login => customer.email, :password => customer.password } }

        before(:each) do
          do_post_create(attributes)
        end

        # Variables
        it "should not have current user" do
          subject.current_user.should be_nil
        end

        # Response
        it { should_not assign_to(:customer) }
        it { should respond_with(:success) }
  
        # Content
        it { should_not set_the_flash } # This controller technically doesn't set the flash
        it { should render_template("layouts/application") }
        it { should render_template :new}
        it "has locked message in alert" do
          flash = response.request.env["rack.session"]["flash"]
          flash.alert.should match(/account is locked/)
        end
      end
    end

    context "as cancelled customer" do
      include_context "with cancelled customer"

      context "with valid login" do
        let(:attributes) { { :login => customer.email, :password => customer.password } }

        before(:each) do
          do_post_create(attributes)
        end

        # Variables
        it "should not have current user" do
          subject.current_user.should be_nil
        end

        # Response
        it { should_not assign_to(:customer) }
        it { should respond_with(:redirect) }
        it { should redirect_to(new_customer_session_path) }
  
        # Content
        it { should set_the_flash[:alert].to(/account has been cancelled/) }
      end
    end

    context "as authenticated customer" do
      include_context "with authenticated customer"
      let(:attributes) { { :login => customer.email, :password => customer.password } }

      before(:each) do
        do_post_create(attributes)
      end

      # Variables
      it "should have current customer" do
        subject.current_customer.should_not be_nil
      end

      it { should_not assign_to(:customer) }
      it { should respond_with(:redirect) }
      it { should redirect_to(customer_home_path) }

      # Content
      it { should set_the_flash[:alert].to(/already signed in/) }
    end

    context "as authenticated store" do
      include_context "with authenticated store"
      let(:customer) { FactoryGirl.create(:confirmed_customer) }
      let(:attributes) { { :login => customer.email, :password => customer.password } }

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
      let(:customer) { FactoryGirl.create(:confirmed_customer) }
      let(:attributes) { { :login => customer.email, :password => customer.password } }

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

  describe "#destroy", :destroy => true do
    context "as unauthenticated customer" do
      include_context "with unauthenticated customer"

      before(:each) do
        do_delete_destroy
      end

      # Variables
      it "should not have current_user" do
        subject.current_user.should be_nil
      end

      # Response
      it { should_not assign_to(:customer) }
      it { should respond_with(:redirect) }
      it { should redirect_to(home_path) }

      # Content
      it { should_not set_the_flash }
    end
    
    context "as authenticated customer" do
      include_context "with authenticated customer"

      before(:each) do
        do_delete_destroy
      end

      # Variables
      it "should not have current_user" do
        subject.current_user.should be_nil
      end

      # Response
      it { should_not assign_to(:customer) }
      it { should respond_with(:redirect) }
      it { should redirect_to(home_path) }

      # Content
      it { should set_the_flash[:notice].to(/Signed out successfully/) }
    end

    context "as authenticated store" do
      include_context "with authenticated store"

      before(:each) do
        do_delete_destroy
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
        do_delete_destroy
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

  describe "#scope_conflict", :scope_conflict => true do
    context "as unauthenticated customer" do
      include_context "with unauthenticated customer"
      
      before(:each) do
        do_get_scope_conflict
      end

      # Variables
      it "should not have current user" do
        subject.current_user.should be_nil
      end

      # Response
      it { should respond_with(:redirect) }
      it { should redirect_to(new_customer_session_path) }

      # Content
      it { should_not set_the_flash }

      # Behavior
      it "should not set 'pre_conflict_path'" do
        session[:pre_conflict_path].should be_nil
      end
    end

    context "as authenticated customer" do
      include_context "with authenticated customer"
      
      before(:each) do
        do_get_scope_conflict
      end

      # Variables
      it "should have current customer" do
        subject.current_customer.should_not be_nil
      end

      # Response
      it { should respond_with(:redirect) }
      it { should redirect_to(customer_home_path) }

      # Content
      it { should_not set_the_flash }

      # Behavior
      it "should not set 'pre_conflict_path'" do
        session[:pre_conflict_path].should be_nil
      end
    end

    context "as authenticated store" do
      include_context "with authenticated store"
      
      before(:each) do
        do_get_scope_conflict
      end

      # Variables
      it "should have current store" do
        subject.current_store.should_not be_nil
      end

      # Response
      it { should respond_with(:success) }

      # Content
      it { should_not set_the_flash }
      it { should render_template("layouts/application") }
      it { should render_template(:scope_conflict) }

      # Behavior
      it "should set 'pre_conflict_path'" do
        session[:pre_conflict_path].should eq("/customer/edit")
      end
    end

    context "as authenticated employee" do
      include_context "with authenticated employee"
      
      before(:each) do
        do_get_scope_conflict
      end

      # Variables
      it "should have current employee" do
        subject.current_employee.should_not be_nil
      end

      # Response
      it { should respond_with(:success) }

      # Content
      it { should_not set_the_flash }
      it { should render_template("layouts/application") }
      it { should render_template(:scope_conflict) }

      # Behavior
      it "should set 'pre_conflict_path'" do
        session[:pre_conflict_path].should eq("/customer/edit")
      end
    end
  end

  describe "#resolve_conflict", :resolve_conflict => true do
    context "as unauthenticated customer" do
      include_context "with unauthenticated customer"
      
      before(:each) do
        do_delete_resolve_conflict
      end

      # Variables
      it "should not have current user" do
        subject.current_user.should be_nil
      end

      # Response
      it { should respond_with(:redirect) }
      it { should redirect_to(new_customer_session_path) }

      # Content
      it { should_not set_the_flash }
    end

    context "as authenticated customer" do
      include_context "with authenticated customer"
      
      before(:each) do
        do_delete_resolve_conflict
      end

      # Variables
      it "should have current customer" do
        subject.current_customer.should be_nil
      end

      # Response
      it { should respond_with(:redirect) }
      it { should redirect_to(new_customer_session_path) }

      # Content
      it { should_not set_the_flash }
    end

    context "as authenticated store" do
      include_context "with authenticated store"
      
      before(:each) do
        do_delete_resolve_conflict
      end

      # Variables
      it "should have current store" do
        subject.current_store.should be_nil
      end

      # Response
      it { should respond_with(:redirect) }
      it { should redirect_to(new_customer_session_path) }

      # Content
      it { should_not set_the_flash }
    end

    context "as authenticated employee" do
      include_context "with authenticated employee"
      
      before(:each) do
        do_delete_resolve_conflict
      end

      # Variables
      it "should have current employee" do
        subject.current_employee.should be_nil
      end

      # Response
      it { should respond_with(:redirect) }
      it { should redirect_to(new_customer_session_path) }

      # Content
      it { should_not set_the_flash }
    end
  end
end