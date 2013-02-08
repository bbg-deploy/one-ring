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
    let(:customer) do
      FactoryGirl.build(:customer)
    end
    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:customer]
      customer.confirm!
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
        it { should redirect_to(customer_home_path)  }

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
        it { should render_template(:new)  }

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
      it { should redirect_to(new_customer_session_path)  }

      # Content
      it { should set_the_flash[:alert].to(/need to sign in or sign up/) }
    end
  end
  
  context "As an authenticated customer" do
    let(:customer) do
      FactoryGirl.create(:customer)
    end
    before { 
      @request.env["devise.mapping"] = Devise.mappings[:customer]
      sign_in customer
    }
    
  end
end