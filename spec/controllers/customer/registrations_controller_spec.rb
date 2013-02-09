require 'spec_helper'

describe Customer::RegistrationsController do
  include Devise::TestHelpers

  describe "routing", :routing => true do
    it { should route(:get, "/customer/sign_up").to(:action => :new) }
    it { should route(:post, "/customer").to(:action => :create) }
    it { should route(:get, "/customer/edit").to(:action => :edit) }
    it { should route(:put, "/customer").to(:action => :update) }
    it { should route(:delete, "/customer").to(:action => :destroy) }
  end

  context "as anonymous user", :anonymous => true do
    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:customer]
    end

    it "does not have a current customer" do
      subject.current_customer.should be_nil
    end

    describe "#new", :new => true do
      before(:each) do
        get :new, :format => 'html'
      end

      # Response
      it { should assign_to(:customer) }
      it { should respond_with(:success) }

      # Content
      it { should_not set_the_flash }
    end

    describe "#create", :create => true do
      context "with valid attributes" do
        before(:each) do
          attributes = FactoryGirl.build(:customer_attributes_hash)
          post :create, :customer => attributes, :format => 'html'
        end

#       it { should permit(:username, :email, :email_confirmation, :password, :password_confirmation).for(:create) }
#       it { should permit(:first_name, :middle_name, :last_name, :date_of_birth, :social_security_number).for(:create) }
#       it { should permit(:mailing_address_attributes, :phone_number_attributes).for(:create) }

        # Response
        it { should assign_to(:customer) }
        it { should respond_with(:redirect) }
        it { should redirect_to(home_path) }

        # Content
        it { should set_the_flash[:notice].to(/message with a confirmation link/) }

        # Behavior
        it "creates a new customer" do
          expect{
            attributes = FactoryGirl.build(:customer_attributes_hash)
            post :create, :customer => attributes, :format => 'html'
          }.to change(Customer,:count).by(1)
        end

        it "is not signed in after registration" do
          attributes = FactoryGirl.build(:customer_attributes_hash)
          post :create, :customer => attributes, :format => 'html'
          subject.current_customer.should be_nil
        end
      end
      
      context "with invalid attributes" do
        before(:each) do
          attributes = FactoryGirl.build(:customer_attributes_hash, :username => nil)
          post :create, :customer => attributes, :format => 'html'
        end

        # Response
        it { should assign_to(:customer) }
        it { should respond_with(:success) }
        it { should render_template(:new) }

        # Content
        it { should set_the_flash[:error].to(/was a problem/) }

        # Behavior
        it "does not creates a new customer" do
          expect{
            attributes = FactoryGirl.build(:customer_attributes_hash, :username => nil)
            post :create, :customer => attributes, :format => 'html'
          }.to_not change(Customer,:count)
        end

        it "is not signed in after registration" do
          attributes = FactoryGirl.build(:customer_attributes_hash)
          post :create, :customer => attributes, :format => 'html'
          subject.current_customer.should be_nil
        end
      end
    end

    describe "#edit", :edit => true do
      before(:each) do
        get :edit, :format => 'html'
      end

      # Response
      it { should_not assign_to(:customer) }
      it { should redirect_to(new_customer_session_path) }

      # Content
      it { should set_the_flash[:alert].to(/need to sign in or sign up/) }
    end

    describe "#update", :update => true do
      before(:each) do
        attributes = FactoryGirl.build(:customer_attributes_hash)
        put :update, :customer => attributes, :format => 'html'
      end

      # Response
      it { should_not assign_to(:customer) }
      it { should redirect_to(new_customer_session_path) }

      # Content
      it { should set_the_flash[:alert].to(/need to sign in or sign up/) }
    end

    describe "#destroy", :destroy => true do
      before(:each) do
        delete :destroy, :format => 'html'
      end

      # Response
      it { should_not assign_to(:customer) }
      it { should redirect_to(new_customer_session_path) }

      # Content
      it { should set_the_flash[:alert].to(/need to sign in or sign up/) }
    end

    describe "#cancel", :cancel => true do
      before(:each) do
        get :cancel, :format => 'html'
      end

      # Response
      it { should_not assign_to(:customer) }
      it { should redirect_to(new_customer_registration_path) }

      # Content
      it { should_not set_the_flash }
    end
  end
  
  context "as unconfirmed authenticated customer", :unconfirmed => true do
    let(:customer) do
      FactoryGirl.create(:customer)
    end
    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:customer]
      sign_in customer
      reset_email
    end
 
    describe "#new", :new => true do
      before(:each) do
        get :new, :format => 'html'
      end

      # Response
      it { should_not assign_to(:customer) }
      it { should respond_with(:redirect) }
      it { should redirect_to(new_customer_session_path) }

      # Content
      it { should set_the_flash[:alert].to(/confirm your account before continuing/) }
    end

    describe "#create", :create => true do
      before(:each) do
        attributes = FactoryGirl.build(:customer_attributes_hash)
        post :create, :customer => attributes, :format => 'html'
      end

      # Response
      it { should_not assign_to(:customer) }
      it { should respond_with(:redirect) }
      it { should redirect_to(new_customer_session_path) }

      # Content
      it { should set_the_flash[:alert].to(/confirm your account before continuing/) }
    end

    describe "#edit", :edit => true do
      before(:each) do
        get :edit, :format => 'html'
      end

      # Response
      it { should_not assign_to(:customer) }
      it { should respond_with(:redirect) }
      it { should redirect_to(new_customer_session_path) }

      # Content
      it { should set_the_flash[:alert].to(/confirm your account before continuing/) }
    end

    describe "#update", :update => true do
      before(:each) do
        attributes = FactoryGirl.build(:customer_attributes_hash)
        put :update, :customer => attributes, :format => 'html'
      end

      # Response
      it { should_not assign_to(:customer) }
      it { should respond_with(:redirect) }
      it { should redirect_to(new_customer_session_path) }

      # Content
      it { should set_the_flash[:alert].to(/confirm your account before continuing/) }
    end

    describe "#destroy", :destroy => true do
      before(:each) do
        delete :destroy, :format => 'html'
      end

      # Response
      it { should_not assign_to(:customer) }
      it { should respond_with(:redirect) }
      it { should redirect_to(new_customer_session_path) }

      # Content
      it { should set_the_flash[:alert].to(/confirm your account before continuing/) }
    end

    describe "#cancel", :cancel => true do
      before(:each) do
        get :cancel, :format => 'html'
      end

      # Response
      it { should_not assign_to(:customer) }
      it { should respond_with(:redirect) }
      it { should redirect_to(new_customer_session_path) }

      # Content
      it { should set_the_flash[:alert].to(/confirm your account before continuing/) }
    end
  end

  context "as confirmed authenticated customer", :confirmed => true do
    let(:customer) do
      FactoryGirl.create(:customer)
    end
    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:customer]
      customer.confirm!
      sign_in customer
      reset_email
    end
    
    it "has a current customer" do
      subject.current_customer.should_not be_nil
    end

    describe "#new", :new => true do
      before(:each) do
        get :new, :format => 'html'
      end

      # Response
      it { should_not assign_to(:customer) }
      it { should redirect_to(customer_home_path) }

      # Content
      it { should set_the_flash[:alert].to(/already signed in/) }
    end

    describe "#create", :create => true do
      before(:each) do
        attributes = FactoryGirl.build(:customer_attributes_hash)
        post :create, :customer => attributes, :format => 'html'
      end

      # Response
      it { should_not assign_to(:customer) }
      it { should redirect_to(customer_home_path) }

      # Content
      it { should set_the_flash[:alert].to(/already signed in/) }
    end

    describe "#edit", :edit => true do
      before(:each) do
        get :edit, :format => 'html'
      end

      # Response
      it { should assign_to(:customer) }
      it { should respond_with(:success) }

      # Content
      it { should_not set_the_flash }
    end

    describe "#update", :update => true do
      context "with new password" do
        context "without password confirmation" do
          before(:each) do
            attributes = {:password => "newpass", :current_password => customer.current_password}
            put :update, :customer => attributes, :format => 'html'
          end
          
          # Response
          it { should assign_to(:customer) }
          it { should respond_with(:success) }
    
          # Content
          it { should_not set_the_flash }
          it { should render_template(:edit) }
        end

        context "with password confirmation" do
          before(:each) do
            attributes = {:password => "newpass", :password_confirmation => "newpass", :current_password => customer.password}
            put :update, :customer => attributes, :format => 'html'
          end
          
          # Response
          it { should assign_to(:customer) }
          it { should redirect_to(customer_home_path) }
    
          # Content
          it { should set_the_flash[:notice].to(/updated your account successfully/) }
        end
      end

      context "with invalid attributes" do
        context "without current_password" do
          before(:each) do
            attributes = FactoryGirl.build(:customer_attributes_hash, :username => nil)
            put :update, :customer => attributes, :format => 'html'
          end
          
          # Response
          it { should assign_to(:customer) }
          it { should respond_with(:success) }
    
          # Content
          it { should_not set_the_flash }
          it { should render_template(:edit) }
        end

        context "with current_password" do
          before(:each) do
            attributes = FactoryGirl.build(:customer_attributes_hash, :username => nil)
            attributes.merge!(:current_password => customer.password)
            put :update, :customer => attributes, :format => 'html'
          end
          
          # Response
          it { should assign_to(:customer) }
          it { should respond_with(:success) }
    
          # Content
          it { should_not set_the_flash }
          it { should render_template(:edit) }
        end
      end

      context "with valid attributes (same email)" do
        let(:attributes) { FactoryGirl.build(:customer_attributes_hash, :email => customer.email).except(:email_confirmation) }
        context "without current_password" do
          before(:each) do
            put :update, :customer => attributes, :format => 'html'
          end
          
          # Response
          it { should assign_to(:customer) }
          it { should respond_with(:success) }
    
          # Content
          it { should_not set_the_flash }
          it { should render_template(:edit) }
        end

        context "with current_password" do
          before(:each) do
            attributes.merge!(:current_password => customer.password)
            put :update, :customer => attributes, :format => 'html'
          end
          
          # Response
          it { should assign_to(:customer) }
          it { should redirect_to(customer_home_path) }
    
          # Content
          it { should set_the_flash[:notice].to(/updated your account successfully/) }
        end
      end

      context "with valid attributes (new email)" do
        let(:attributes) { FactoryGirl.build(:customer_attributes_hash) }
        context "without current_password" do
          before(:each) do
            put :update, :customer => attributes, :format => 'html'
          end
          
          # Response
          it { should assign_to(:customer) }
          it { should respond_with(:success) }
    
          # Content
          it { should_not set_the_flash }
          it { should render_template(:edit) }
        end

        context "with current_password" do
          before(:each) do
            attributes.merge!(:current_password => customer.password)
            put :update, :customer => attributes, :format => 'html'
          end
          
          # Response
          it { should assign_to(:customer) }
          it { should redirect_to(customer_home_path) }
    
          # Content
          it { should set_the_flash[:notice].to(/updated your account successfully, but we need to verify your new email/) }
          it "should unconfirm the customer" do
            customer.unconfirmed_email.should be_nil
            customer.reload
            customer.unconfirmed_email.should_not be_nil
          end
        end
      end
    end

    describe "#destroy", :destroy => true do
      before(:each) do
        delete :destroy, :format => 'html'
      end

      # Response
      it { should assign_to(:customer) }
      it { should redirect_to(home_path) }

      # Content
      it { should set_the_flash[:notice].to(/account was successfully cancelled/) }

      # Behavior
      it "should be 'canceled'" do
        customer.cancelled?.should be_true
      end

      it "should still persist in database" do
        customer.reload
        customer.should be_valid
      end
    end

    describe "#cancel", :cancel => true do
      before(:each) do
        get :cancel, :format => 'html'
      end

      # Response
      it { should_not assign_to(:customer) }
      it { should redirect_to(customer_home_path) }

      # Content
      it { should set_the_flash[:alert].to(/already signed in/) }
    end
  end
end