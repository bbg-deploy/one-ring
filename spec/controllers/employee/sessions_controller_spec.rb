require 'spec_helper'

describe Employee::SessionsController do
  describe "routing", :routing => true do
    it { should route(:get, "/employee/sign_in").to(:action => :new) }
    it { should route(:post, "/employee/sign_in").to(:action => :create) }
    it { should route(:delete, "/employee/sign_out").to(:action => :destroy) }
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
    context "as unauthenticated employee" do
      include_context "with unauthenticated employee"

      describe "invalid login" do
        before(:each) do
          @request.env["devise.mapping"] = Devise.mappings[:employee]
          attributes = {:login => employee.email, :password => "wrongpass"}
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
        it { should_not assign_to(:employee) }
        it { should respond_with(:success) }
  
        # Content
        it { should_not set_the_flash }
        it { should render_template(:new) }

        # Behavior
        it "should increment failed attempts count" do
          employee.reload
          employee.failed_attempts.should eq(1)
        end
      end

      describe "locks after multiple invalid logins" do
        before(:each) do
          employee.failed_attempts = 5
          employee.save
          @request.env["devise.mapping"] = Devise.mappings[:employee]
          attributes = {:login => employee.email, :password => "wrongpass#{Random.new.rand(100)}"}
          post :create, :employee => attributes, :format => 'html'
        end

        # Variables
        it "should not have current user" do
          subject.current_user.should be_nil
          subject.current_employee.should be_nil
        end

        # Response
        it { should_not assign_to(:employee) }
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
          @request.env["devise.mapping"] = Devise.mappings[:employee]
          attributes = {:login => employee.email, :password => employee.password}
          post :create, :employee => attributes, :format => 'html'
        end

        # Variables
        it "should have current employee" do
          subject.current_user.should_not be_nil
          subject.current_employee.should_not be_nil
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
          @request.env["devise.mapping"] = Devise.mappings[:employee]
          attributes = {:login => employee.username, :password => employee.password}
          post :create, :employee => attributes, :format => 'html'
        end

        # Variables
        it "should have current employee" do
          subject.current_user.should_not be_nil
          subject.current_employee.should_not be_nil
        end

        # Response
        it { should assign_to(:employee) }
        it { should respond_with(:redirect) }
        it { should redirect_to(employee_home_path) }
  
        # Content
        it { should set_the_flash[:notice].to(/Signed in successfully/) }
      end

      describe "redirects to correct path" do
        context "without referrer" do
          before(:each) do
            @request.env["devise.mapping"] = Devise.mappings[:employee]
            attributes = {:login => employee.username, :password => employee.password}
            post :create, :employee => attributes, :format => 'html'
          end
  
          # Variables
          it "should have current employee" do
            subject.current_user.should_not be_nil
            subject.current_employee.should_not be_nil
          end
  
          # Response
          it { should assign_to(:employee) }
          it { should respond_with(:redirect) }
          it { should redirect_to(employee_home_path) }
    
          # Content
          it { should set_the_flash[:notice].to(/Signed in successfully/) }
        end
        
        context "with referer" do
          before(:each) do
            @request.env["devise.mapping"] = Devise.mappings[:employee]
            session[:post_auth_path] = "/employee/edit"
            attributes = {:login => employee.username, :password => employee.password}
            post :create, :employee => attributes, :format => 'html'
          end
  
          # Variables
          it "should have current employee" do
            subject.current_user.should_not be_nil
            subject.current_employee.should_not be_nil
          end
  
          # Response
          it { should assign_to(:employee) }
          it { should respond_with(:redirect) }
          it { should redirect_to(edit_employee_registration_path) }
    
          # Content
          it { should set_the_flash[:notice].to(/Signed in successfully/) }
        end
        
        context "with referer and pre_conflict_path" do
          before(:each) do
            @request.env["devise.mapping"] = Devise.mappings[:employee]
            session[:post_auth_path] = "/employee"
            session[:pre_conflict_path] = "/employee/edit"
            attributes = {:login => employee.username, :password => employee.password}
            post :create, :employee => attributes, :format => 'html'
          end
  
          # Variables
          it "should have current employee" do
            subject.current_user.should_not be_nil
            subject.current_employee.should_not be_nil
          end
  
          # Response
          it { should assign_to(:employee) }
          it { should respond_with(:redirect) }
          it { should redirect_to(edit_employee_registration_path) }
    
          # Content
          it { should set_the_flash[:notice].to(/Signed in successfully/) }
        end
      end
    end
          
    context "as unconfirmed employee" do
      include_context "with unconfirmed employee"

      describe "valid login" do
        before(:each) do
          @request.env["devise.mapping"] = Devise.mappings[:employee]
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

    context "as locked employee" do
      include_context "with locked employee"

      describe "valid login" do
        before(:each) do
          @request.env["devise.mapping"] = Devise.mappings[:employee]
          attributes = {:login => employee.email, :password => employee.password}
          post :create, :employee => attributes, :format => 'html'
        end

        # Variables
        it "should not have current user" do
          subject.current_user.should be_nil
          subject.current_employee.should be_nil
        end

        # Response
        it { should_not assign_to(:employee) }
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

    context "as cancelled employee" do
      include_context "with cancelled employee"

      describe "valid login" do
        before(:each) do
          @request.env["devise.mapping"] = Devise.mappings[:employee]
          attributes = {:login => employee.email, :password => employee.password}
          post :create, :employee => attributes, :format => 'html'
        end

        it "should be cancelled" do
          employee.cancelled?.should be_true
          employee.active_for_authentication?.should be_false
        end

        # Response
        it { should_not assign_to(:employee) }
        it { should respond_with(:redirect) }
        it { should redirect_to(new_employee_session_path) }
  
        # Content
        it { should set_the_flash[:alert].to(/account has been cancelled/) }
      end
    end

    context "as authenticated employee" do
      include_context "with authenticated employee"

      before(:each) do
        @request.env["devise.mapping"] = Devise.mappings[:employee]
        attributes = {:login => employee.username, :password => employee.password}
        post :create, :employee => attributes, :format => 'html'
      end

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

  describe "#destroy", :destroy => true do
    context "as unauthenticated employee" do
      include_context "with unauthenticated employee"

      before(:each) do
        @request.env["devise.mapping"] = Devise.mappings[:employee]
        delete :destroy, :format => 'html'
      end

      it { should_not assign_to(:employee) }
      it { should respond_with(:redirect) }
      it { should redirect_to(home_path) }

      # Content
      it { should_not set_the_flash }
    end
    
    context "as authenticated employee" do
      include_context "with authenticated employee"

      before(:each) do
        @request.env["devise.mapping"] = Devise.mappings[:employee]
        delete :destroy, :format => 'html'
      end

      it { should_not assign_to(:employee) }
      it { should respond_with(:redirect) }
      it { should redirect_to(home_path) }

      # Content
      it { should set_the_flash[:notice].to(/Signed out successfully/) }    
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

  describe "#scope_conflict", :scope_conflict => true do
    context "as unauthenticated employee" do
      include_context "with unauthenticated employee"
      
      before(:each) do
        @request.env["devise.mapping"] = Devise.mappings[:employee]
        @request.env["HTTP_REFERER"] = "/employee/edit"
        get :scope_conflict, :format => 'html'
      end

      # Variables
      it "should not have current user" do
        subject.current_user.should be_nil
        subject.current_employee.should be_nil
      end

      # Response
      it { should respond_with(:redirect) }
      it { should redirect_to(new_employee_session_path) }

      # Content
      it { should_not set_the_flash }

      # Behavior
      it "should not set 'pre_conflict_path'" do
        session[:pre_conflict_path].should be_nil
      end
    end

    context "as authenticated employee" do
      include_context "with authenticated employee"
      
      before(:each) do
        @request.env["devise.mapping"] = Devise.mappings[:employee]
        @request.env["HTTP_REFERER"] = "/employee/edit"
        get :scope_conflict, :format => 'html'
      end

      # Variables
      it "should have current employee" do
        subject.current_user.should_not be_nil
        subject.current_employee.should_not be_nil
      end

      # Response
      it { should respond_with(:redirect) }
      it { should redirect_to(employee_home_path) }

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
        @request.env["devise.mapping"] = Devise.mappings[:employee]
        @request.env["HTTP_REFERER"] = "/employee/edit"
        get :scope_conflict, :format => 'html'
      end

      # Variables
      it "should have current customer" do
        subject.current_user.should_not be_nil
        subject.current_employee.should be_nil
        subject.current_customer.should_not be_nil
      end

      # Response
      it { should respond_with(:success) }
      it { should render_template(:scope_conflict) }

      # Content
      it { should_not set_the_flash }

      # Behavior
      it "should set 'pre_conflict_path'" do
        session[:pre_conflict_path].should eq("/employee/edit")
      end
    end

    context "as authenticated store" do
      include_context "with authenticated store"
      
      before(:each) do
        @request.env["devise.mapping"] = Devise.mappings[:employee]
        @request.env["HTTP_REFERER"] = "/employee/edit"
        get :scope_conflict, :format => 'html'
      end

      # Variables
      it "should have current store" do
        subject.current_user.should_not be_nil
        subject.current_employee.should be_nil
        subject.current_store.should_not be_nil
      end

      # Response
      it { should respond_with(:success) }
      it { should render_template(:scope_conflict) }

      # Content
      it { should_not set_the_flash }

      # Behavior
      it "should set 'pre_conflict_path'" do
        session[:pre_conflict_path].should eq("/employee/edit")
      end
    end
  end

  describe "#resolve_conflict", :resolve_conflict => true do
    context "as unauthenticated employee" do
      include_context "with unauthenticated employee"
      
      before(:each) do
        @request.env["devise.mapping"] = Devise.mappings[:employee]
        delete :resolve_conflict, :format => 'html'
      end

      # Variables
      it "should not have current user" do
        subject.current_user.should be_nil
        subject.current_employee.should be_nil
      end

      # Response
      it { should respond_with(:redirect) }
      it { should redirect_to(new_employee_session_path) }

      # Content
      it { should_not set_the_flash }
    end

    context "as authenticated employee" do
      include_context "with authenticated employee"
      
      before(:each) do
        @request.env["devise.mapping"] = Devise.mappings[:employee]
        delete :resolve_conflict, :format => 'html'
      end

      # Variables
      it "should not have current user" do
        subject.current_user.should be_nil
        subject.current_employee.should be_nil
      end

      # Response
      it { should respond_with(:redirect) }
      it { should redirect_to(new_employee_session_path) }

      # Content
      it { should_not set_the_flash }
    end

    context "as authenticated customer" do
      include_context "with authenticated customer"
      
      before(:each) do
        @request.env["devise.mapping"] = Devise.mappings[:employee]
        delete :resolve_conflict, :format => 'html'
      end

      # Variables
      it "should not have current user" do
        subject.current_user.should be_nil
        subject.current_employee.should be_nil
        subject.current_customer.should be_nil
      end

      # Response
      it { should respond_with(:redirect) }
      it { should redirect_to(new_employee_session_path) }

      # Content
      it { should_not set_the_flash }
    end

    context "as authenticated store" do
      include_context "with authenticated store"
      
      before(:each) do
        @request.env["devise.mapping"] = Devise.mappings[:employee]
        delete :resolve_conflict, :format => 'html'
      end

      # Variables
      it "should not have current user" do
        subject.current_user.should be_nil
        subject.current_employee.should be_nil
        subject.current_store.should be_nil
      end

      # Response
      it { should respond_with(:redirect) }
      it { should redirect_to(new_employee_session_path) }

      # Content
      it { should_not set_the_flash }
    end
  end
end