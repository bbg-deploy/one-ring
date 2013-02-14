require 'spec_helper'

describe Customer::PaymentProfilesController do
  include Devise::TestHelpers

  describe "routing", :routing => true do
    let(:customer) { FactoryGirl.create(:customer) }
    let(:payment_profile) { FactoryGirl.create(:payment_profile) }

    it { should route(:get, "/customer/payment_methods").to(:action => :index) }
    it { should route(:get, "/customer/payment_methods/new").to(:action => :new) }
    it { should route(:post, "/customer/payment_methods").to(:action => :create) }
    it { should route(:get, "/customer/payment_methods/1").to(:action => :show, :id => 1) }
    it { should route(:get, "/customer/payment_methods/1/edit").to(:action => :edit, :id => 1) }
    it { should route(:put, "/customer/payment_methods/1").to(:action => :update, :id => 1) }
    it { should route(:delete, "/customer/payment_methods/1").to(:action => :destroy, :id => 1) }
  end

  describe "#new", :new => true do
    context "as unauthenticated customer" do
      include_context "as unauthenticated customer"
      before(:each) do
        get :new, :format => 'html'
      end

      # Response
      it { should_not assign_to(:payment_profile) }
      it { should respond_with(:redirect) }
      it { should redirect_to(new_customer_session_path) }

      # Content
      it { should set_the_flash[:alert].to(/need to sign in or sign up/) }
    end

    context "as authenticated customer" do
      include_context "as authenticated customer"
      before(:each) do
        get :new, :format => 'html'
      end

      # Response
      it { should assign_to(:payment_profile) }
      it { should respond_with(:success) }

      # Content
      it { should_not set_the_flash }
      it { should render_template(:new) }
    end
  end

  describe "#create", :create => true do
    context "as unauthenticated customer" do
      include_context "as unauthenticated customer"
      describe "creating bank account profile" do
        let(:attributes) { FactoryGirl.build(:payment_profile_bank_account_attributes_hash).except(:customer) }
        before(:each) do
          post :create, :payment_profile => attributes, :format => 'html'
        end
  
        # Response
        it { should_not assign_to(:payment_profile) }
        it { should respond_with(:redirect) }
        it { should redirect_to(new_customer_session_path) }
  
        # Content
        it { should set_the_flash[:alert].to(/need to sign in or sign up/) }
      end

      describe "creating credit card profile" do
        let(:attributes) { FactoryGirl.build(:payment_profile_bank_account_attributes_hash).except(:customer) }
        before(:each) do
          post :create, :payment_profile => attributes, :format => 'html'
        end
  
        # Response
        it { should_not assign_to(:payment_profile) }
        it { should respond_with(:redirect) }
        it { should redirect_to(new_customer_session_path) }
  
        # Content
        it { should set_the_flash[:alert].to(/need to sign in or sign up/) }
      end
    end

    context "as authenticated customer" do
      include_context "as authenticated customer"
      describe "creating bank account profile" do
        let(:attributes) { FactoryGirl.build(:payment_profile_bank_account_attributes_hash).except(:customer) }
        before(:each) do
          post :create, :payment_profile => attributes, :format => 'html'
        end
  
        # Response
        it { should assign_to(:payment_profile) }
        it { should respond_with(:redirect) }
        it { should redirect_to(customer_payment_profile_path(PaymentProfile.last)) }
  
        # Content
        it { should set_the_flash[:notice].to(/Successfully created payment/) }
      end

      describe "creating credit card profile" do
        let(:attributes) { FactoryGirl.build(:payment_profile_bank_account_attributes_hash).except(:customer) }
        before(:each) do
          post :create, :payment_profile => attributes, :format => 'html'
        end
  
        # Response
        it { should assign_to(:payment_profile) }
        it { should respond_with(:redirect) }
        it { should redirect_to(customer_payment_profile_path(PaymentProfile.last)) }
  
        # Content
        it { should set_the_flash[:notice].to(/Successfully created payment/) }
      end
    end
  end

  describe "#show", :show => true do
    context "as unauthenticated customer" do
      include_context "as unauthenticated customer"
      
      let(:payment_profile) { FactoryGirl.create(:payment_profile) }
      before(:each) do
        get :show, :id => payment_profile.id, :format => 'html'
      end

      # Response
      it { should_not assign_to(:payment_profile) }
      it { should respond_with(:redirect) }
      it { should redirect_to(new_customer_session_path) }

      # Content
      it { should set_the_flash[:alert].to(/need to sign in or sign up/) }
    end
    
    context "as authenticated customer" do
      include_context "as authenticated customer"

      describe "with customer's payment_profile" do
        let(:payment_profile) { FactoryGirl.create(:payment_profile, :customer => customer) }
        before(:each) do
          get :show, :id => payment_profile.id, :format => 'html'
        end

        # Response
        it { should assign_to(:payment_profile) }
        it { should respond_with(:success) }
  
        # Content
        it { should_not set_the_flash }
        it { should render_template(:show) }
      end

      describe "with other customer's payment_profile" do
        let(:payment_profile) { FactoryGirl.create(:payment_profile) }
        before(:each) do
          get :show, :id => payment_profile.id, :format => 'html'
        end

        # Response
        it { should assign_to(:payment_profile) }
        it { should respond_with(:redirect) }
        it { should redirect_to(customer_home_path) }
  
        # Content
        it { should set_the_flash[:alert].to(/Access denied/) }
      end
    end
  end

  describe "#edit", :edit => true do
    context "as unauthenticated customer" do
      include_context "as unauthenticated customer"
      
      let(:payment_profile) { FactoryGirl.create(:payment_profile) }
      before(:each) do
        get :edit, :id => payment_profile.id, :format => 'html'
      end

      # Response
      it { should_not assign_to(:payment_profile) }
      it { should respond_with(:redirect) }
      it { should redirect_to(new_customer_session_path) }

      # Content
      it { should set_the_flash[:alert].to(/need to sign in or sign up/) }
    end
    
    context "as authenticated customer" do
      include_context "as authenticated customer"

      describe "with customer's payment_profile" do
        let(:payment_profile) { FactoryGirl.create(:payment_profile, :customer => customer) }
        before(:each) do
          get :edit, :id => payment_profile.id, :format => 'html'
        end

        # Response
        it { should assign_to(:payment_profile) }
        it { should respond_with(:success) }
  
        # Content
        it { should_not set_the_flash }
        it { should render_template(:edit) }
      end

      describe "with other customer's payment_profile" do
        let(:payment_profile) { FactoryGirl.create(:payment_profile) }
        before(:each) do
          get :edit, :id => payment_profile.id, :format => 'html'
        end

        # Response
        it { should assign_to(:payment_profile) }
        it { should respond_with(:redirect) }
        it { should redirect_to(customer_home_path) }
  
        # Content
        it { should set_the_flash[:alert].to(/Access denied/) }
      end
    end
  end

  describe "#update", :update => true do
    context "as unauthenticated customer" do
      include_context "as unauthenticated customer"
      
      let(:payment_profile) { FactoryGirl.create(:payment_profile) }
      let(:attributes) { { :first_name => "Billy" } }
      before(:each) do
        put :update, :id => payment_profile.id, :attributes => attributes, :format => 'html'
      end

      # Response
      it { should_not assign_to(:payment_profile) }
      it { should respond_with(:redirect) }
      it { should redirect_to(new_customer_session_path) }

      # Content
      it { should set_the_flash[:alert].to(/need to sign in or sign up/) }
    end
    
    context "as authenticated customer" do
      include_context "as authenticated customer"

      describe "with customer's payment_profile" do
        let(:payment_profile) { FactoryGirl.create(:payment_profile, :customer => customer) }
        let(:attributes) { { :first_name => "Billy" } }
        before(:each) do
          put :update, :id => payment_profile.id, :attributes => attributes, :format => 'html'
        end

        # Response
        it { should assign_to(:payment_profile) }
        it { should respond_with(:redirect) }
        it { should redirect_to(customer_payment_profile_path(payment_profile.id)) }
  
        # Content
        it { should set_the_flash[:notice].to(/Successfully updated/) }
      end

      describe "with other customer's payment_profile" do
        let(:payment_profile) { FactoryGirl.create(:payment_profile) }
        let(:attributes) { { :first_name => "Billy" } }
        before(:each) do
          put :update, :id => payment_profile.id, :attributes => attributes, :format => 'html'
        end

        # Response
        it { should assign_to(:payment_profile) }
        it { should respond_with(:redirect) }
        it { should redirect_to(customer_home_path) }
  
        # Content
        it { should set_the_flash[:alert].to(/Access denied/) }
      end
    end
  end

  describe "#destroy", :destroy => true do
    context "as unauthenticated customer" do
      include_context "as unauthenticated customer"
      
      let(:payment_profile) { FactoryGirl.create(:payment_profile) }
      before(:each) do
        delete :destroy, :id => payment_profile.id, :format => 'html'
      end

      # Response
      it { should_not assign_to(:payment_profile) }
      it { should respond_with(:redirect) }
      it { should redirect_to(new_customer_session_path) }

      # Content
      it { should set_the_flash[:alert].to(/need to sign in or sign up/) }
    end
    
    context "as authenticated customer" do
      include_context "as authenticated customer"

      describe "with customer's payment_profile" do
        let(:payment_profile) { FactoryGirl.create(:payment_profile, :customer => customer) }
        before(:each) do
          delete :destroy, :id => payment_profile.id, :format => 'html'
        end

        # Response
        it { should assign_to(:payment_profile) }
        it { should respond_with(:redirect) }
        it { should redirect_to(customer_payment_profiles_path) }
  
        # Content
        it { should set_the_flash[:notice].to(/Successfully deleted/) }
      end

      describe "with other customer's payment_profile" do
        let(:payment_profile) { FactoryGirl.create(:payment_profile) }
        before(:each) do
          delete :destroy, :id => payment_profile.id, :format => 'html'
        end

        # Response
        it { should assign_to(:payment_profile) }
        it { should respond_with(:redirect) }
        it { should redirect_to(customer_home_path) }
  
        # Content
        it { should set_the_flash[:alert].to(/Access denied/) }
      end
    end
  end
end