require 'spec_helper'

describe Store::RegistrationsController do
  describe "routing", :routing => true do
    it { should route(:get, "/store/sign_up").to(:action => :new) }
    it { should route(:post, "/store").to(:action => :create) }
    it { should route(:get, "/store/edit").to(:action => :edit) }
    it { should route(:put, "/store").to(:action => :update) }
    it { should route(:delete, "/store").to(:action => :destroy) }
    it { should route(:get, "/store/cancel").to(:action => :cancel) }
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
        subject.current_store.should be_nil
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

    context "as authenticated customer" do
      include_context "with authenticated customer"
      before(:each) do
        @request.env["devise.mapping"] = Devise.mappings[:store]
        get :new, :format => 'html'
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

      describe "with valid attributes" do
        let(:attributes) { FactoryGirl.build(:store_attributes_hash) }
        before(:each) do
          @request.env["devise.mapping"] = Devise.mappings[:store]
          post :create, :store => attributes, :format => 'html'
        end

#       it { should permit(:username, :email, :email_confirmation, :password, :password_confirmation).for(:create) }
#       it { should permit(:first_name, :middle_name, :last_name, :date_of_birth, :social_security_number).for(:create) }
#       it { should permit(:mailing_address_attributes, :phone_number_attributes).for(:create) }

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
        it { should set_the_flash[:notice].to(/administrator approval/) }

        # Behavior
        it "creates a new store" do
          expect{
            attributes = FactoryGirl.build(:store_attributes_hash)
            post :create, :store => attributes, :format => 'html'
          }.to change(Store,:count).by(1)
        end

        it "is not signed in after registration" do
          subject.current_store.should be_nil
        end

        it "sends administrator approval notice" do
          last_email.should_not be_nil
          last_email.to.should eq([attributes[:email]])
          last_email.body.should match(/administrator approval/)
        end
      end
      
      describe "with invalid attributes" do
        let(:attributes) { FactoryGirl.build(:store_attributes_hash, :username => nil) }
        before(:each) do
          @request.env["devise.mapping"] = Devise.mappings[:store]
          post :create, :store => attributes, :format => 'html'
        end

        # Variables
        it "should not have current user" do
          subject.current_user.should be_nil
          subject.current_store.should be_nil
        end

        # Response
        it { should assign_to(:store) }
        it { should respond_with(:success) }
        it { should render_template(:new) }

        # Content
        it { should set_the_flash[:alert].to(/was a problem/) }

        # Behavior
        it "does not creates a new store" do
          expect{
            attributes = FactoryGirl.build(:store_attributes_hash, :username => nil)
            post :create, :store => attributes, :format => 'html'
          }.to_not change(Store,:count)
        end

        it "is not signed in after registration" do
          attributes = FactoryGirl.build(:store_attributes_hash)
          post :create, :store => attributes, :format => 'html'
          subject.current_store.should be_nil
        end

        it "does not send confirmation email" do
          last_email.should be_nil
        end
      end
    end    

    context "as authenticated store" do
      include_context "with authenticated store"

      before(:each) do
        @request.env["devise.mapping"] = Devise.mappings[:store]
        attributes = FactoryGirl.build(:store_attributes_hash)
        post :create, :store => attributes, :format => 'html'
      end

      # Variables
      it "should have current user" do
        subject.current_user.should_not be_nil
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
        @request.env["devise.mapping"] = Devise.mappings[:store]
        store = FactoryGirl.create(:store)
        attributes = FactoryGirl.build(:store_attributes_hash)
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
        attributes = FactoryGirl.build(:store_attributes_hash)
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

  describe "#edit", :edit => true do
    context "as unauthenticated store" do
      include_context "with unauthenticated store"

      before(:each) do
        @request.env["devise.mapping"] = Devise.mappings[:store]
        get :edit, :format => 'html'
      end

      # Variables
      it "should not have current user" do
        subject.current_user.should be_nil
        subject.current_store.should be_nil
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
        @request.env["devise.mapping"] = Devise.mappings[:store]
        get :edit, :format => 'html'
      end

      # Variables
      it "should have current store" do
        subject.current_user.should_not be_nil
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
        @request.env["devise.mapping"] = Devise.mappings[:store]
        get :edit, :format => 'html'
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
      it { should redirect_to(new_store_session_path) }

      # Content
      it { should set_the_flash[:alert].to(/need to sign in or sign up/) }
    end

    context "as authenticated employee" do
      include_context "with authenticated employee"
      before(:each) do
        @request.env["devise.mapping"] = Devise.mappings[:store]
        get :edit, :format => 'html'
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
      it { should redirect_to(new_store_session_path) }

      # Content
      it { should set_the_flash[:alert].to(/need to sign in or sign up/) }
    end
  end

  describe "#update", :update => true do
    context "as unauthenticated store" do
      include_context "with unauthenticated store"

      before(:each) do
        @request.env["devise.mapping"] = Devise.mappings[:store]
        attributes = FactoryGirl.build(:store_attributes_hash)
        put :update, :store => attributes, :format => 'html'
      end

      # Variables
      it "should not have current user" do
        subject.current_user.should be_nil
        subject.current_store.should be_nil
      end

      # Response
      it { should_not assign_to(:store) }
      it { should redirect_to(new_store_session_path) }

      # Content
      it { should set_the_flash[:alert].to(/need to sign in or sign up/) }
    end
    
    context "as authenticated store" do
      include_context "with authenticated store"

      describe "with new password" do
        describe "without password confirmation" do
          let(:attributes) { {:password => "newpass", :current_password => store.current_password} }
          before(:each) do
            @request.env["devise.mapping"] = Devise.mappings[:store]
            put :update, :store => attributes, :format => 'html'
          end
              
          # Variables
          it "should have current store" do
            subject.current_user.should_not be_nil
            subject.current_store.should_not be_nil
          end

          # Response
          it { should assign_to(:store) }
          it { should respond_with(:success) }
    
          # Content
          it { should set_the_flash[:alert].to(/was a problem/) }
          it { should render_template(:edit) }
        end

        describe "with password confirmation" do
          let(:attributes) { {:password => "newpass", :password_confirmation => "newpass", :current_password => store.password} }

          before(:each) do
            @request.env["devise.mapping"] = Devise.mappings[:store]
            put :update, :store => attributes, :format => 'html'
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
          it { should set_the_flash[:notice].to(/updated your account successfully/) }
        end
      end

      describe "with invalid attributes" do
        let(:attributes) { FactoryGirl.build(:store_attributes_hash, :username => nil) }
        before(:each) do
          @request.env["devise.mapping"] = Devise.mappings[:store]
          put :update, :store => attributes, :format => 'html'
        end
        
        # Variables
        it "should have current store" do
          subject.current_user.should_not be_nil
          subject.current_store.should_not be_nil
        end

        # Response
        it { should assign_to(:store) }
        it { should respond_with(:success) }
  
        # Content
          it { should set_the_flash[:alert].to(/was a problem/) }
        it { should render_template(:edit) }
      end

      describe "with valid attributes (same email)" do
        let(:attributes) { FactoryGirl.build(:store_attributes_hash, :email => store.email).except(:email_confirmation) }

        describe "without current_password" do
          before(:each) do
            @request.env["devise.mapping"] = Devise.mappings[:store]
            put :update, :store => attributes, :format => 'html'
          end
          
          # Variables
          it "should have current store" do
            subject.current_user.should_not be_nil
            subject.current_store.should_not be_nil
          end
  
          # Response
          it { should assign_to(:store) }
          it { should respond_with(:success) }
    
          # Content
          it { should set_the_flash[:alert].to(/was a problem/) }
          it { should render_template(:edit) }
        end

        describe "with current_password" do
          before(:each) do
            @request.env["devise.mapping"] = Devise.mappings[:store]
            attributes.merge!(:current_password => store.password)
            put :update, :store => attributes, :format => 'html'
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
          it { should set_the_flash[:notice].to(/updated your account successfully/) }
        end
      end

      describe "with valid attributes (new email)" do
        let(:attributes) { FactoryGirl.build(:store_attributes_hash) }
        context "without current_password" do
          before(:each) do
            @request.env["devise.mapping"] = Devise.mappings[:store]
            put :update, :store => attributes, :format => 'html'
          end
          
          # Variables
          it "should have current store" do
            subject.current_user.should_not be_nil
            subject.current_store.should_not be_nil
          end

          # Response
          it { should assign_to(:store) }
          it { should respond_with(:success) }
    
          # Content
          it { should set_the_flash[:alert].to(/was a problem/) }
          it { should render_template(:edit) }
        end

        describe "with current_password" do
          before(:each) do
            @request.env["devise.mapping"] = Devise.mappings[:store]
            attributes.merge!(:current_password => store.password)
            put :update, :store => attributes, :format => 'html'
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
          it { should set_the_flash[:notice].to(/updated your account successfully/) }

          # Behavior
          it "does not send an email" do
            last_email.should be_nil
          end
        end
      end
    end

    context "as authenticated customer" do
      include_context "with authenticated customer"
      before(:each) do
        @request.env["devise.mapping"] = Devise.mappings[:store]
        attributes = FactoryGirl.build(:store_attributes_hash)
        put :update, :store => attributes, :format => 'html'
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
      it { should redirect_to(new_store_session_path) }

      # Content
      it { should set_the_flash[:alert].to(/need to sign in or sign up/) }
    end

    context "as authenticated employee" do
      include_context "with authenticated employee"
      before(:each) do
        @request.env["devise.mapping"] = Devise.mappings[:store]
        attributes = FactoryGirl.build(:store_attributes_hash)
        put :update, :store => attributes, :format => 'html'
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
      it { should redirect_to(new_store_session_path) }

      # Content
      it { should set_the_flash[:alert].to(/need to sign in or sign up/) }
    end
  end

  describe "#destroy", :destroy => true do
    context "as unauthenticated store" do
      include_context "with unauthenticated store"

      before(:each) do
        @request.env["devise.mapping"] = Devise.mappings[:store]
        delete :destroy, :format => 'html'
      end

      # Variables
      it "should not have current user" do
        subject.current_user.should be_nil
        subject.current_store.should be_nil
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
        @request.env["devise.mapping"] = Devise.mappings[:store]
        delete :destroy, :format => 'html'
      end

      # Variables
      it "should not have current store (logged out)" do
        subject.current_user.should be_nil
        subject.current_store.should be_nil
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
        @request.env["devise.mapping"] = Devise.mappings[:store]
        delete :destroy, :format => 'html'
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
      it { should redirect_to(new_store_session_path) }

      # Content
      it { should set_the_flash[:alert].to(/need to sign in or sign up/) }
    end

    context "as authenticated employee" do
      include_context "with authenticated employee"
      before(:each) do
        @request.env["devise.mapping"] = Devise.mappings[:store]
        delete :destroy, :format => 'html'
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
      it { should redirect_to(new_store_session_path) }

      # Content
      it { should set_the_flash[:alert].to(/need to sign in or sign up/) }
    end
  end

  describe "#cancel", :cancel => true do
    context "as unauthenticated store" do
      include_context "with unauthenticated store"

      before(:each) do
        @request.env["devise.mapping"] = Devise.mappings[:store]
        get :cancel, :format => 'html'
      end

      # Variables
      it "should not have current user" do
        subject.current_user.should be_nil
        subject.current_store.should be_nil
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
        @request.env["devise.mapping"] = Devise.mappings[:store]
        get :cancel, :format => 'html'
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

    context "as authenticated customer" do
      include_context "with authenticated customer"
      before(:each) do
        @request.env["devise.mapping"] = Devise.mappings[:store]
        get :cancel, :format => 'html'
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
        get :cancel, :format => 'html'
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