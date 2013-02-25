require 'spec_helper'

describe Store::ConfirmationsController do
  describe "routing", :routing => true do
    it { should route(:get, "/store/confirmation/new").to(:action => :new) }
    it { should route(:post, "/store/confirmation").to(:action => :create) }
    it { should route(:get, "/store/confirmation").to(:action => :show) }
  end

  describe "#new", :new => true do
    context "as unauthenticated store" do
      include_context "with unauthenticated store"

      before(:each) do
        @request.env["devise.mapping"] = Devise.mappings[:store]
        get :new, :format => 'html'
      end

      # Variables
      it "should not have current user" do
        subject.current_user.should be_nil
      end

      # Response
      it { should assign_to(:store) }
      it { should respond_with(:success) }

      # Content
      it { should_not set_the_flash }
      it { should render_template(:new) }
    end

    context "as authenticated store" do
      include_context "with authenticated store"
      before(:each) do
        @request.env["devise.mapping"] = Devise.mappings[:store]
        get :new, :format => 'html'
      end

      # Variables
      it "should not have current user" do
        subject.current_user.should_not be_nil
        subject.current_store.should_not be_nil
      end

      # Response
      it { should_not assign_to(:store) }
      it { should respond_with(:redirect) }
      it { should redirect_to(store_home_path) }

      # Content
      it { should set_the_flash[:alert].to(/already signed in/) }
    end

    context "as authenticated customer" do
      include_context "with authenticated customer"
      before(:each) do
        @request.env["devise.mapping"] = Devise.mappings[:store]
        get :new, :format => 'html'
      end

      # Variables
      it "should not have current customer" do
        subject.current_user.should_not be_nil
        subject.current_store.should be_nil
        subject.current_customer.should_not be_nil
      end

      # Response
      it { should_not assign_to(:store) }
      it { should respond_with(:redirect) }
      it { should redirect_to(store_scope_conflict_path) }

      # Content
      it { should_not set_the_flash }
    end

    context "as authenticated employee" do
      include_context "with authenticated employee"
      before(:each) do
        @request.env["devise.mapping"] = Devise.mappings[:store]
        get :new, :format => 'html'
      end

      # Variables
      it "should have current employee" do
        subject.current_user.should_not be_nil
        subject.current_store.should be_nil
        subject.current_employee.should_not be_nil
      end

      # Response
      it { should_not assign_to(:store) }
      it { should respond_with(:redirect) }
      it { should redirect_to(store_scope_conflict_path) }

      # Content
      it { should_not set_the_flash }
    end
  end

  describe "#create", :create => true do
    context "as unauthenticated store" do
      include_context "with unauthenticated store"

      describe "with invalid email" do
        before(:each) do
          @request.env["devise.mapping"] = Devise.mappings[:store]
          attributes = {:email => "fake@email.com"}
          post :create, :store => attributes, :format => 'html'
        end

        # Parameters
#       it { should permit(:email).for(:create) }

        # Variables
        it "should not have current user" do
          subject.current_user.should be_nil
          subject.current_store.should be_nil
        end
  
        # Response
        it { should assign_to(:store) }
        it { should respond_with(:success) }

        # Content
        it { should_not set_the_flash }
        it { should render_template(:new) }

        # Behavior
        it "should not send confirmation email" do
          last_email.should be_nil
        end
      end

      describe "with valid email" do
        before(:each) do
          @request.env["devise.mapping"] = Devise.mappings[:store]
          attributes = {:email => store.email}
          post :create, :store => attributes, :format => 'html'
        end

        # Parameters
#       it { should permit(:email).for(:create) }

        # Variables
        it "should not have current user" do
          subject.current_user.should be_nil
          subject.current_store.should be_nil
        end
  
        # Response
        it { should assign_to(:store) }
        it { should respond_with(:success) }

        # Content
        it { should render_template(:new) }

        # Behavior
        it "should not send email" do
          last_email.should be_nil
        end
      end
    end
    
    context "with unconfirmed store" do
      include_context "with unconfirmed store"

      describe "with invalid email" do
        before(:each) do
          @request.env["devise.mapping"] = Devise.mappings[:store]
          attributes = {:email => "fake@email.com"}
          post :create, :store => attributes, :format => 'html'
        end

        # Parameters
#       it { should permit(:email).for(:create) }

        # Variables
        it "should not have current user" do
          subject.current_user.should be_nil
          subject.current_store.should be_nil
        end

        # Response
        it { should assign_to(:store) }
        it { should respond_with(:success) }

        # Content
        it { should_not set_the_flash }
        it { should render_template(:new) }

        # Behavior
        it "should not send confirmation email" do
          last_email.should be_nil
        end
      end

      describe "with valid email" do
        before(:each) do
          @request.env["devise.mapping"] = Devise.mappings[:store]
          attributes = {:email => store.email}
          post :create, :store => attributes, :format => 'html'
        end

        # Parameters
#       it { should permit(:email).for(:create) }

        # Variables
        it "should not have current user" do
          subject.current_user.should be_nil
          subject.current_store.should be_nil
        end

        # Response
        it { should assign_to(:store) }
        it { should respond_with(:redirect) }
        it { should redirect_to(home_path) }

        # Content
        it { should set_the_flash[:notice].to(/email with instructions about how to confirm/) }

        # Behavior
        it "should send confirmation email" do
          last_email.should_not be_nil
          last_email.to.should eq([store.email])
          last_email.body.should match(/#{store.confirmation_token}/)
        end
      end
    end

    context "as authenticated store" do
      include_context "with authenticated store"

      describe "with valid email" do
        before(:each) do
          @request.env["devise.mapping"] = Devise.mappings[:store]
          attributes = {:email => store.email}
          post :create, :store => attributes, :format => 'html'
        end
  
        # Parameters
  #       it { should permit(:email).for(:create) }
  
        # Variables
        it "should have current store" do
          subject.current_user.should_not be_nil
          subject.current_store.should_not be_nil
        end

        # Response
        it { should_not assign_to(:store) }
        it { should respond_with(:redirect) }
        it { should redirect_to(store_home_path) }
  
        # Content
        it { should set_the_flash[:alert].to(/already signed in/) }
      end
    end

    context "as authenticated customer" do
      include_context "with authenticated customer"
      before(:each) do
        @request.env["devise.mapping"] = Devise.mappings[:store]
        store = FactoryGirl.create(:store)
        attributes = {:email => store.email}
        post :create, :store => attributes, :format => 'html'
      end

      # Variables
      it "should have current customer" do
        subject.current_user.should_not be_nil
        subject.current_store.should be_nil
        subject.current_customer.should_not be_nil
      end

      # Response
      it { should_not assign_to(:store) }
      it { should respond_with(:redirect) }
      it { should redirect_to(store_scope_conflict_path) }

      # Content
      it { should_not set_the_flash }
    end

    context "as authenticated employee" do
      include_context "with authenticated employee"
      before(:each) do
        @request.env["devise.mapping"] = Devise.mappings[:store]
        store = FactoryGirl.create(:store)
        attributes = {:email => store.email}
        post :create, :store => attributes, :format => 'html'
      end

      # Variables
      it "should have current employee" do
        subject.current_user.should_not be_nil
        subject.current_store.should be_nil
        subject.current_employee.should_not be_nil
      end

      # Response
      it { should_not assign_to(:store) }
      it { should respond_with(:redirect) }
      it { should redirect_to(store_scope_conflict_path) }

      # Content
      it { should_not set_the_flash }
    end
  end

  describe "#show", :show => true do
    context "as unconfirmed store" do
      include_context "with unconfirmed store"
      
      describe "with invalid token" do
        before(:each) do
          @request.env["devise.mapping"] = Devise.mappings[:store]
          @request.env['QUERY_STRING'] = "confirmation_token="
          get :show, :confirmation_token => "1234234234", :format => 'html'
        end

        # Variables
        it "should not have current user" do
          subject.current_user.should be_nil
          subject.current_store.should be_nil
        end

        # Response
        it { should assign_to(:store) }
        it { should respond_with(:success) }

        # Content
        it { should_not set_the_flash }
        it { should render_template(:new) }
      end

      describe "with valid token" do
        before(:each) do
          @request.env["devise.mapping"] = Devise.mappings[:store]
          @request.env['QUERY_STRING'] = "confirmation_token="
          get :show, :confirmation_token => "#{store.confirmation_token}", :format => 'html'
        end        

        # Variables
        it "should have current store" do
          subject.current_user.should_not be_nil
          subject.current_store.should_not be_nil
        end

        # Response
        it { should assign_to(:store) }
        it { should redirect_to(store_home_path) }
  
        # Content
        it { should set_the_flash[:notice].to(/successfully confirmed/) }
      end
    end
    
    context "as authenticated store" do
      include_context "with authenticated store"

      describe "with valid token" do
        before(:each) do
          @request.env["devise.mapping"] = Devise.mappings[:store]
          @request.env['QUERY_STRING'] = "confirmation_token="
          get :show, :confirmation_token => "#{store.confirmation_token}", :format => 'html'
        end        

        # Variables
        it "should have current store" do
          subject.current_user.should_not be_nil
          subject.current_store.should_not be_nil
        end

        # Response
        it { should_not assign_to(:store) }
        it { should redirect_to(store_home_path) }
  
        # Content
        it { should set_the_flash[:alert].to(/already signed in/) }
      end
    end

    context "as authenticated customer" do
      include_context "with authenticated customer"
      before(:each) do
        @request.env["devise.mapping"] = Devise.mappings[:store]
        @request.env['QUERY_STRING'] = "confirmation_token="
        store = FactoryGirl.create(:store)
        get :show, :confirmation_token => "#{store.confirmation_token}", :format => 'html'
      end

      # Variables
      it "should have current store" do
        subject.current_user.should_not be_nil
        subject.current_store.should be_nil
        subject.current_customer.should_not be_nil
      end

      # Response
      it { should_not assign_to(:store) }
      it { should respond_with(:redirect) }
      it { should redirect_to(store_scope_conflict_path) }

      # Content
      it { should_not set_the_flash }
    end

    context "as authenticated employee" do
      include_context "with authenticated employee"
      before(:each) do
        @request.env["devise.mapping"] = Devise.mappings[:store]
        @request.env['QUERY_STRING'] = "confirmation_token="
        store = FactoryGirl.create(:store)
        get :show, :confirmation_token => "#{store.confirmation_token}", :format => 'html'
      end

      # Variables
      it "should have current employee" do
        subject.current_user.should_not be_nil
        subject.current_store.should be_nil
        subject.current_employee.should_not be_nil
      end

      # Response
      it { should_not assign_to(:store) }
      it { should respond_with(:redirect) }
      it { should redirect_to(store_scope_conflict_path) }

      # Content
      it { should_not set_the_flash }
    end
  end
end