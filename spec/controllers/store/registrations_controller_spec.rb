require 'spec_helper'

describe Store::RegistrationsController do
  # Controller Shared Methods
  #----------------------------------------------------------------------------
  def do_get_new
    @request.env["devise.mapping"] = Devise.mappings[:store]
    get :new, :format => 'html'
  end

  def do_post_create(attributes)
    @request.env["devise.mapping"] = Devise.mappings[:store]
    post :create, :store => attributes, :format => 'html'
  end

  def do_get_edit
    @request.env["devise.mapping"] = Devise.mappings[:store]
    get :edit, :format => 'html'
  end

  def do_put_update(attributes)
    @request.env["devise.mapping"] = Devise.mappings[:store]
    put :update, :store => attributes, :format => 'html'
  end

  def do_delete_destroy
    @request.env["devise.mapping"] = Devise.mappings[:store]
    delete :destroy, :format => 'html'
  end

  def do_delete_cancel_account
    @request.env["devise.mapping"] = Devise.mappings[:store]
    delete :cancel_account, :format => 'html'
  end

  def do_get_cancel
    @request.env["devise.mapping"] = Devise.mappings[:store]
    get :cancel, :format => 'html'
  end

  # Routing
  #----------------------------------------------------------------------------
  describe "routing", :routing => true do
    it { should route(:get, "/store/sign_up").to(:action => :new) }
    it { should route(:post, "/store").to(:action => :create) }
    it { should route(:get, "/store/edit").to(:action => :edit) }
    it { should route(:put, "/store").to(:action => :update) }
    it { should route(:delete, "/store").to(:action => :destroy) }
    it { should route(:delete, "/store/cancel_account").to(:action => :cancel_account) }
    it { should route(:get, "/store/cancel").to(:action => :cancel) }
  end

  # Public Methods
  #----------------------------------------------------------------------------
  describe "#new", :new => true do
    context "as unauthenticated store" do
      include_context "with unauthenticated store"
      
      before(:each) do
        do_get_new
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
        do_get_new
      end

      # Variables
      it "should have current store" do
        subject.current_store.should_not be_nil
      end

      # Response
      it { should_not assign_to(:store) }
      it { should redirect_to(store_home_path) }

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
      it { should_not assign_to(:store) }
      it { should respond_with(:redirect) }
      it { should redirect_to(store_scope_conflict_path) }

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

      context "without observers" do
        context "with valid attributes" do
          let(:attributes) { FactoryGirl.build(:store_attributes_hash) }

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
          it { should assign_to(:store) }
          it { should respond_with(:redirect) }
          it { should redirect_to(home_path) }
  
          # Content
          it { should set_the_flash[:notice].to(/need administrator approval/) }
  
          # Behavior
          it "creates a new store" do
            Store.last.try(:email).should eq(attributes[:email])
          end
  
          it "does not send confirmation email" do
            confirmation_email_sent_to?(attributes[:email]).should be_false
          end

          it "sends pending approval email" do
            pending_admin_approval_email_sent_to?(attributes[:email]).should be_true
          end
        end

        context "with invalid attributes" do
          let(:attributes) { FactoryGirl.build(:store_attributes_hash, :username => nil) }
          before(:each) do
            do_post_create(attributes)
          end
  
          # Variables
          it "should not have current user" do
            subject.current_user.should be_nil
          end
  
          # Response
          it { should assign_to(:store) }
          it { should respond_with(:success) }
          it { should render_template(:new) }
  
          # Content
          it { should set_the_flash[:alert].to(/was a problem/) }
  
          # Behavior
          it "does not creates a new store" do
            Store.last.try(:email).should_not eq(attributes[:email])
          end
    
          it "does not send confirmation email" do
            confirmation_email_sent_to?(attributes[:email]).should be_false
          end
        end
      end

      context "with observers" do
        before(:each) do
          Store.observers.enable :store_observer
        end
        
        context "with valid attributes" do
          let(:attributes) { FactoryGirl.build(:store_attributes_hash) }

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
          it { should assign_to(:store) }
          it { should respond_with(:redirect) }
          it { should redirect_to(home_path) }
  
          # Content
          it { should set_the_flash[:notice].to(/need administrator approval/) }
  
          # Behavior
          it "creates a new store" do
            Store.last.try(:email).should eq(attributes[:email])
          end

          it "does not send confirmation email" do
            confirmation_email_sent_to?(attributes[:email]).should be_false
          end

          it "sends pending approval email" do
            pending_admin_approval_email_sent_to?(attributes[:email]).should be_true
          end
          
          it "send admin alert" do
            admin_email_alert?.should be_true
          end
        end

        context "with invalid attributes" do
          let(:attributes) { FactoryGirl.build(:store_attributes_hash, :username => nil) }

          before(:each) do
            do_post_create(attributes)
          end
          
          # Variables
          it "should not have current user" do
            subject.current_user.should be_nil
          end
  
          # Response
          it { should assign_to(:store) }
          it { should respond_with(:success) }
          it { should render_template(:new) }
  
          # Content
          it { should set_the_flash[:alert].to(/was a problem/) }
  
          # Behavior
          it "does not creates a new store" do
            Customer.last.try(:email).should_not eq(attributes[:email])
          end

          it "does not send confirmation email" do
            confirmation_email_sent_to?(attributes[:email]).should be_false
          end

          it "does not send admin alert" do
            admin_email_alert?.should be_false
          end
        end
      end
    end    

    context "as authenticated store" do
      include_context "with authenticated store"
      let(:attributes) { FactoryGirl.build(:store_attributes_hash) }

      before(:each) do
        do_post_create(attributes)
      end

      # Variables
      it "should have current user" do
        subject.current_user.should_not be_nil
      end

      # Response
      it { should_not assign_to(:store) }
      it { should redirect_to(store_home_path) }

      # Content
      it { should set_the_flash[:alert].to(/already signed in/) }
    end

    context "as authenticated customer" do
      include_context "with authenticated customer"
      let(:attributes) { FactoryGirl.build(:store_attributes_hash) }

      before(:each) do
        do_post_create(attributes)
      end

      # Variables
      it "should have current customer" do
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
      let(:attributes) { FactoryGirl.build(:store_attributes_hash) }
      
      before(:each) do
        do_post_create(attributes)
      end

      # Variables
      it "should have current employee" do
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

  describe "#edit", :edit => true do
    context "as unauthenticated store" do
      include_context "with unauthenticated store"

      before(:each) do
        do_get_edit
      end

      # Variables
      it "should not have current user" do
        subject.current_user.should be_nil
      end

      # Response
      it { should_not assign_to(:store) }
      it { should redirect_to(new_store_session_path) }

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
      it { should assign_to(:store) }
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
      it { should_not assign_to(:store) }
      it { should respond_with(:redirect) }
      it { should redirect_to(new_store_session_path) }

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
      it { should_not assign_to(:store) }
      it { should respond_with(:redirect) }
      it { should redirect_to(new_store_session_path) }

      # Content
      it { should set_the_flash[:alert].to(/need to sign in or sign up/) }
    end
  end

  describe "#update", :update => true do
    context "as unauthenticated store" do
      include_context "with unauthenticated store"
      let(:attributes) { FactoryGirl.build(:store_attributes_hash) }

      before(:each) do
        do_put_update(attributes)
      end

      # Variables
      it "should not have current user" do
        subject.current_user.should be_nil
      end

      # Response
      it { should_not assign_to(:store) }
      it { should redirect_to(new_store_session_path) }

      # Content
      it { should set_the_flash[:alert].to(/need to sign in or sign up/) }
    end
    
    context "as authenticated store" do
      include_context "with authenticated store"

      context "with valid attributes (name)" do
        let(:attributes) { { :name => "Gorilla Industries", :current_password => store.password } }

        before(:each) do
          do_put_update(attributes)
        end
        
        it "should have current store" do
          subject.current_store.should_not be_nil
        end

        # Response
        it { should assign_to(:store) }
        it { should redirect_to(store_home_path) }
  
        # Content
        it { should set_the_flash[:notice].to(/updated your account successfully/) }

        # Behavior
        it "should change name" do
          store.reload
          store.name.should eq("Gorilla Industries")
        end

        it "should not send confirmation email" do
          confirmation_email_sent_to?(store.email).should be_false
        end
      end

      context "with valid attributes (password)" do
        let(:attributes) { { :password => "newpass", :password_confirmation => "newpass", :current_password => store.password } }

        before(:each) do
          do_put_update(attributes)
        end
        
        it "should have current store" do
          subject.current_store.should_not be_nil
        end

        # Response
        it { should assign_to(:store) }
        it { should redirect_to(store_home_path) }
  
        # Content
        it { should set_the_flash[:notice].to(/updated your account successfully/) }

        # Behavior
        it "should change password" do
          old_password = store.encrypted_password
          store.reload
          store.encrypted_password.should_not eq(old_password)
        end

        it "should not send confirmation email" do
          confirmation_email_sent_to?(store.email).should be_false
        end
      end

      context "with valid attributes (new email address)" do
        let(:attributes) { { :email => "new@email.com", :email_confirmation => "new@email.com", :current_password => store.password } }

        before(:each) do
          webmock_authorize_net_all_successful
          do_put_update(attributes)
        end

        it "should have current store" do
          subject.current_store.should_not be_nil
        end

        # Response
        it { should assign_to(:store) }
        it { should redirect_to(store_home_path) }
  
        # Content
        it { should set_the_flash[:notice].to(/updated your account successfully/) }

        # Behavior
        it "should change email" do
          store.reload
          store.unconfirmed_email.should eq(attributes[:email])
        end

        it "should send confirmation email to new address" do
          confirmation_email_sent_to?(store.email).should be_false
          confirmation_email_sent_to?(attributes[:email]).should be_true
        end            
      end

      context "with invalid attributes (no current password)" do
        let(:attributes) { { :name => "Gorilla Industries" } }

        before(:each) do
          do_put_update(attributes)
        end
        
        it "should have current store" do
          subject.current_store.should_not be_nil
        end

        # Response
        it { should assign_to(:store) }
        it { should respond_with(:success) }
        it { should render_template(:edit) }
  
        # Content
        it { should set_the_flash[:alert].to(/problem with some of your information/) }

        # Behavior
        it "should not change name" do
          store.reload
          store.name.should_not eq("Gorilla Industries")
        end

        it "should not send confirmation email" do
          confirmation_email_sent_to?(store.email).should be_false
        end
      end

      context "with invalid attributes (email confirmation mismatch)" do
        let(:attributes) { { :email => "new@email.com", :email_confirmation => "mismatch@email.com", :current_password => store.password } }

        before(:each) do
          do_put_update(attributes)
        end
        
        it "should have current store" do
          subject.current_store.should_not be_nil
        end

        # Response
        it { should assign_to(:store) }
        it { should respond_with(:success) }
        it { should render_template(:edit) }
  
        # Content
        it { should set_the_flash[:alert].to(/problem with some of your information/) }

        # Behavior
        it "should not change email" do
          store.reload
          store.email.should_not eq("new@email.com")
          store.unconfirmed_email.should_not eq("new@email.com")
        end

        it "should not send confirmation email" do
          confirmation_email_sent_to?(store.email).should be_false
        end
      end
    end

    context "as authenticated customer" do
      include_context "with authenticated customer"
      let(:attributes) { FactoryGirl.build(:store_attributes_hash) }

      before(:each) do
        do_put_update(attributes)
      end

      # Variables
      it "should have current customer" do
        subject.current_customer.should_not be_nil
      end

      # Response
      it { should_not assign_to(:store) }
      it { should respond_with(:redirect) }
      it { should redirect_to(new_store_session_path) }

      # Content
      it { should set_the_flash[:alert].to(/need to sign in or sign up/) }
    end

    context "as authenticated employee" do
      include_context "with authenticated employee"
      let(:attributes) { FactoryGirl.build(:store_attributes_hash) }
      
      before(:each) do
        do_put_update(attributes)
      end

      # Variables
      it "should have current employee" do
        subject.current_employee.should_not be_nil
      end

      # Response
      it { should_not assign_to(:store) }
      it { should respond_with(:redirect) }
      it { should redirect_to(new_store_session_path) }

      # Content
      it { should set_the_flash[:alert].to(/need to sign in or sign up/) }
    end
  end

  describe "#destroy", :destroy => true do
    context "as unauthenticated store" do
      include_context "with unauthenticated store"

      before(:each) do
        do_delete_destroy
      end

      # Variables
      it "should not have current user" do
        subject.current_user.should be_nil
      end

      # Response
      it { should_not assign_to(:store) }
      it { should redirect_to(new_store_session_path) }

      # Content
      it { should set_the_flash[:alert].to(/need to sign in or sign up/) }
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
      it { should assign_to(:store) }
      it { should redirect_to(home_path) }

      # Content
      it { should set_the_flash[:alert].to(/cannot be deleted/) }

      # Behavior
      it "should still persist in database" do
        expect { store.reload }.to_not raise_error
      end
    end

    context "as authenticated customer" do
      include_context "with authenticated customer"
      before(:each) do
        do_delete_destroy
      end

      # Variables
      it "should have current customer" do
        subject.current_customer.should_not be_nil
      end

      # Response
      it { should_not assign_to(:store) }
      it { should respond_with(:redirect) }
      it { should redirect_to(new_store_session_path) }

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
        subject.current_employee.should_not be_nil
      end

      # Response
      it { should_not assign_to(:store) }
      it { should respond_with(:redirect) }
      it { should redirect_to(new_store_session_path) }

      # Content
      it { should set_the_flash[:alert].to(/need to sign in or sign up/) }
    end
  end

  describe "#cancel_account", :cancel_account => true do
    context "as unauthenticated store" do
      include_context "with unauthenticated store"

      before(:each) do
        do_delete_cancel_account
      end

      # Variables
      it "should not have current user" do
        subject.current_user.should be_nil
      end

      # Response
      it { should_not assign_to(:store) }
      it { should redirect_to(new_store_session_path) }

      # Content
      it { should set_the_flash[:alert].to(/need to sign in or sign up/) }
    end
    
    context "as authenticated store" do
      include_context "with authenticated store"
      
      before(:each) do
        do_delete_cancel_account
      end

      # Variables
      it "should not have current store (logged out)" do
        subject.current_user.should be_nil
      end

      # Response
      it { should assign_to(:store) }
      it { should redirect_to(home_path) }

      # Content
      it { should set_the_flash[:notice].to(/account was successfully cancelled/) }

      # Behavior
      it "should be 'cancelled'" do
        store.reload
        store.cancelled?.should be_true
      end

      it "should still persist in database" do
        store.reload
        store.should be_valid
      end
    end

    context "as authenticated customer" do
      include_context "with authenticated customer"
      before(:each) do
        do_delete_cancel_account
      end

      # Variables
      it "should have current customer" do
        subject.current_customer.should_not be_nil
      end

      # Response
      it { should_not assign_to(:store) }
      it { should respond_with(:redirect) }
      it { should redirect_to(new_store_session_path) }

      # Content
      it { should set_the_flash[:alert].to(/need to sign in or sign up/) }
    end

    context "as authenticated employee" do
      include_context "with authenticated employee"

      before(:each) do
        do_delete_cancel_account
      end

      # Variables
      it "should have current employee" do
        subject.current_employee.should_not be_nil
      end

      # Response
      it { should_not assign_to(:store) }
      it { should respond_with(:redirect) }
      it { should redirect_to(new_store_session_path) }

      # Content
      it { should set_the_flash[:alert].to(/need to sign in or sign up/) }
    end
  end

  describe "#cancel", :cancel => true do
    context "as unauthenticated store" do
      include_context "with unauthenticated store"

      before(:each) do
        do_get_cancel
      end

      # Variables
      it "should not have current user" do
        subject.current_user.should be_nil
      end

      # Response
      it { should_not assign_to(:store) }
      it { should redirect_to(new_store_registration_path) }

      # Content
      it { should_not set_the_flash }
    end
    
    context "as authenticated store" do
      include_context "with authenticated store"

      before(:each) do
        do_get_cancel
      end

      # Variables
      it "should have current store" do
        subject.current_store.should_not be_nil
      end

      # Response
      it { should_not assign_to(:store) }
      it { should redirect_to(store_home_path) }

      # Content
      it { should set_the_flash[:alert].to(/already signed in/) }
    end

    context "as authenticated customer" do
      include_context "with authenticated customer"

      before(:each) do
        do_get_cancel
      end

      # Variables
      it "should have current customer" do
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
        do_get_cancel
      end

      # Variables
      it "should have current employee" do
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