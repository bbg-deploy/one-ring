require 'spec_helper'

describe Customer::SessionsController do
  describe "routing", :routing => true do
    it { should route(:get, "/customer/sign_in").to(:action => :new) }
    it { should route(:post, "/customer/sign_in").to(:action => :create) }
    it { should route(:delete, "/customer/sign_out").to(:action => :destroy) }
  end

  describe "#new", :new => true do
    context "as unauthenticated customer" do
      include_context "with unauthenticated customer"
      
      before(:each) do
        @request.env["devise.mapping"] = Devise.mappings[:customer]
        get :new, :format => 'html'
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
    end
    
    context "as authenticated customer" do
      include_context "with authenticated customer"

      before(:each) do
        @request.env["devise.mapping"] = Devise.mappings[:customer]
        get :new, :format => 'html'
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
        @request.env["devise.mapping"] = Devise.mappings[:customer]
        get :new, :format => 'html'
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
        @request.env["devise.mapping"] = Devise.mappings[:customer]
        get :new, :format => 'html'
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
    context "as unauthenticated customer" do
      include_context "with unauthenticated customer"

      describe "invalid login" do
        before(:each) do
          @request.env["devise.mapping"] = Devise.mappings[:customer]
          attributes = {:login => customer.email, :password => "wrongpass"}
          post :create, :customer => attributes, :format => 'html'
        end

        # Parameters
#       it { should permit(:email).for(:create) }

        # Variables
        it "should not have current user" do
          subject.current_user.should be_nil
          subject.current_customer.should be_nil
        end

        # Response
        it { should_not assign_to(:customer) }
        it { should respond_with(:success) }
  
        # Content
        it { should_not set_the_flash }
        it { should render_template(:new) }

        # Behavior
        it "should increment failed attempts count" do
          customer.reload
          customer.failed_attempts.should eq(1)
        end
      end

      describe "locks after multiple invalid logins" do
        before(:each) do
          customer.failed_attempts = 5
          customer.save
          @request.env["devise.mapping"] = Devise.mappings[:customer]
          attributes = {:login => customer.email, :password => "wrongpass#{Random.new.rand(100)}"}
          post :create, :customer => attributes, :format => 'html'
        end

        # Variables
        it "should not have current user" do
          subject.current_user.should be_nil
          subject.current_customer.should be_nil
        end

        # Response
        it { should_not assign_to(:customer) }
        it { should respond_with(:success) }
  
        # Content
        it { should_not set_the_flash }
        it { should render_template(:new) }
        it "has locked message in alert" do
          flash = response.request.env["rack.session"]["flash"]
          flash.alert.should match(/account is locked/)
        end
      end

      describe "valid login (email)" do
        before(:each) do
          @request.env["devise.mapping"] = Devise.mappings[:customer]
          attributes = {:login => customer.email, :password => customer.password}
          post :create, :customer => attributes, :format => 'html'
        end

        # Variables
        it "should have current customer" do
          subject.current_user.should_not be_nil
          subject.current_customer.should_not be_nil
        end

        # Response
        it { should assign_to(:customer) }
        it { should respond_with(:redirect) }
        it { should redirect_to(customer_home_path) }
  
        # Content
        it { should set_the_flash[:notice].to(/Signed in successfully/) }
      end

      describe "valid login (username)" do
        before(:each) do
          @request.env["devise.mapping"] = Devise.mappings[:customer]
          attributes = {:login => customer.username, :password => customer.password}
          post :create, :customer => attributes, :format => 'html'
        end

        # Variables
        it "should have current customer" do
          subject.current_user.should_not be_nil
          subject.current_customer.should_not be_nil
        end

        # Response
        it { should assign_to(:customer) }
        it { should respond_with(:redirect) }
        it { should redirect_to(customer_home_path) }
  
        # Content
        it { should set_the_flash[:notice].to(/Signed in successfully/) }
      end
    end
          
    context "as unconfirmed customer" do
      include_context "with unconfirmed customer"

      describe "valid login" do
        before(:each) do
          @request.env["devise.mapping"] = Devise.mappings[:customer]
          attributes = {:login => customer.email, :password => customer.password}
          post :create, :customer => attributes, :format => 'html'
        end

        # Parameters
#       it { should permit(:email).for(:create) }

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

      describe "valid login" do
        before(:each) do
          @request.env["devise.mapping"] = Devise.mappings[:customer]
          attributes = {:login => customer.email, :password => customer.password}
          post :create, :customer => attributes, :format => 'html'
        end

        # Variables
        it "should not have current user" do
          subject.current_user.should be_nil
          subject.current_customer.should be_nil
        end

        # Response
        it { should_not assign_to(:customer) }
        it { should respond_with(:success) }
  
        # Content
        it { should_not set_the_flash } # This controller technically doesn't set the flash
        it { should render_template :new}
        it "has locked message in alert" do
          flash = response.request.env["rack.session"]["flash"]
          flash.alert.should match(/account is locked/)
        end
      end
    end

    context "as cancelled customer" do
      include_context "with cancelled customer"

      describe "valid login" do
        before(:each) do
          @request.env["devise.mapping"] = Devise.mappings[:customer]
          attributes = {:login => customer.email, :password => customer.password}
          post :create, :customer => attributes, :format => 'html'
        end

        it "should be cancelled" do
          customer.cancelled?.should be_true
          customer.active_for_authentication?.should be_false
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

      before(:each) do
        @request.env["devise.mapping"] = Devise.mappings[:customer]
        attributes = {:login => customer.username, :password => customer.password}
        post :create, :customer => attributes, :format => 'html'
      end

      it { should_not assign_to(:customer) }
      it { should respond_with(:redirect) }
      it { should redirect_to(customer_home_path) }

      # Content
      it { should set_the_flash[:alert].to(/already signed in/) }
    end

    context "as authenticated store" do
      include_context "with authenticated store"

      before(:each) do
        @request.env["devise.mapping"] = Devise.mappings[:customer]
        get :new, :format => 'html'
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
        @request.env["devise.mapping"] = Devise.mappings[:customer]
        get :new, :format => 'html'
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

  describe "#destroy", :destroy => true do
    context "as unauthenticated customer" do
      include_context "with unauthenticated customer"

      before(:each) do
        @request.env["devise.mapping"] = Devise.mappings[:customer]
        delete :destroy, :format => 'html'
      end

      it { should_not assign_to(:customer) }
      it { should respond_with(:redirect) }
      it { should redirect_to(home_path) }

      # Content
      it { should_not set_the_flash }
    end
    
    context "as authenticated customer" do
      include_context "with authenticated customer"

      before(:each) do
        @request.env["devise.mapping"] = Devise.mappings[:customer]
        delete :destroy, :format => 'html'
      end

      it { should_not assign_to(:customer) }
      it { should respond_with(:redirect) }
      it { should redirect_to(home_path) }

      # Content
      it { should set_the_flash[:notice].to(/Signed out successfully/) }    end

    context "as authenticated store" do
      include_context "with authenticated store"

      before(:each) do
        @request.env["devise.mapping"] = Devise.mappings[:customer]
        get :new, :format => 'html'
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
        @request.env["devise.mapping"] = Devise.mappings[:customer]
        get :new, :format => 'html'
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