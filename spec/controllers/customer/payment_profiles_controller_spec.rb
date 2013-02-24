require 'spec_helper'

describe Customer::PaymentProfilesController do
  include Devise::TestHelpers

  describe "routing", :routing => true do
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
      include_context "with unauthenticated customer"
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
      include_context "with authenticated customer"
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
      include_context "with unauthenticated customer"
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

        # Behavior
        it "should not create new PaymentProfile" do
          expect {
            attributes = FactoryGirl.build(:payment_profile_bank_account_attributes_hash).except(:customer)
            post :create, :payment_profile => attributes, :format => 'html'
          }.to_not change(PaymentProfile, :count)
        end
      end

      describe "creating credit card profile" do
        let(:attributes) { FactoryGirl.build(:payment_profile_credit_card_attributes_hash).except(:customer) }
        before(:each) do
          post :create, :payment_profile => attributes, :format => 'html'
        end
  
        # Response
        it { should_not assign_to(:payment_profile) }
        it { should respond_with(:redirect) }
        it { should redirect_to(new_customer_session_path) }
  
        # Content
        it { should set_the_flash[:alert].to(/need to sign in or sign up/) }

        # Behavior
        it "should not create new PaymentProfile" do
          expect {
            attributes = FactoryGirl.build(:payment_profile_credit_card_attributes_hash).except(:customer)
            post :create, :payment_profile => attributes, :format => 'html'
          }.to_not change(PaymentProfile, :count)
        end
      end
    end

    context "as authenticated customer" do
      include_context "with authenticated customer"
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

        # Behavior
        it "should create new PaymentProfile" do
          expect {
            attributes = FactoryGirl.build(:payment_profile_bank_account_attributes_hash).except(:customer)
            post :create, :payment_profile => attributes, :format => 'html'
          }.to change(PaymentProfile, :count).by(1)
        end
      end

      describe "creating credit card profile" do
        let(:attributes) { FactoryGirl.build(:payment_profile_credit_card_attributes_hash).except(:customer) }
        before(:each) do
          post :create, :payment_profile => attributes, :format => 'html'
        end
  
        # Response
        it { should assign_to(:payment_profile) }
        it { should respond_with(:redirect) }
        it { should redirect_to(customer_payment_profile_path(PaymentProfile.last)) }
  
        # Content
        it { should set_the_flash[:notice].to(/Successfully created payment/) }

        # Behavior
        it "should create new PaymentProfile" do
          expect {
            attributes = FactoryGirl.build(:payment_profile_credit_card_attributes_hash).except(:customer)
            post :create, :payment_profile => attributes, :format => 'html'
          }.to change(PaymentProfile, :count).by(1)
        end
      end
    end
  end

  describe "#show", :show => true do
    context "as unauthenticated customer" do
      include_context "with unauthenticated customer"
      
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
      include_context "with authenticated customer"

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
      include_context "with unauthenticated customer"
      
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
      include_context "with authenticated customer"

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
      include_context "with unauthenticated customer"
      
      let(:payment_profile) { FactoryGirl.create(:payment_profile) }
      let(:attributes) { { :first_name => "Billy" } }
      before(:each) do
        put :update, :id => payment_profile.id, :payment_profile => attributes, :format => 'html'
      end

      # Response
      it { should_not assign_to(:payment_profile) }
      it { should respond_with(:redirect) }
      it { should redirect_to(new_customer_session_path) }

      # Content
      it { should set_the_flash[:alert].to(/need to sign in or sign up/) }

      #Behavior
      it "should not update payment profile" do
        payment_profile.first_name.should_not eq("Billy")
        payment_profile.reload
        payment_profile.first_name.should_not eq("Billy")
      end
    end
    
    context "as authenticated customer" do
      include_context "with authenticated customer"

      describe "with customer's payment_profile" do
        let(:payment_profile) { FactoryGirl.create(:payment_profile, :customer => customer) }
        let(:attributes) { { :first_name => "Billy" } }
        before(:each) do
          put :update, :id => payment_profile.id, :payment_profile => attributes, :format => 'html'
        end

        # Response
        it { should assign_to(:payment_profile) }
        it { should respond_with(:redirect) }
        it { should redirect_to(customer_payment_profile_path(payment_profile.id)) }
  
        # Content
        it { should set_the_flash[:notice].to(/Successfully updated/) }
        
        #Behavior
        it "should update payment profile" do
          payment_profile.first_name.should_not eq("Billy")
          payment_profile.reload
          payment_profile.first_name.should eq("Billy")
        end
      end

      describe "with other customer's payment_profile" do
        let(:payment_profile) { FactoryGirl.create(:payment_profile) }
        let(:attributes) { { :first_name => "Billy" } }
        before(:each) do
          put :update, :id => payment_profile.id, :payment_profile => attributes, :format => 'html'
        end

        # Response
        it { should assign_to(:payment_profile) }
        it { should respond_with(:redirect) }
        it { should redirect_to(customer_home_path) }
  
        # Content
        it { should set_the_flash[:alert].to(/Access denied/) }

        #Behavior
        it "should not update payment profile" do
          payment_profile.first_name.should_not eq("Billy")
          payment_profile.reload
          payment_profile.first_name.should_not eq("Billy")
        end
      end
    end
  end

  describe "#destroy", :destroy => true do
    context "as unauthenticated customer" do
      include_context "with unauthenticated customer"
      
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

      # Behavior
      it "should persist PaymentProfile" do
        expect { payment_profile.reload }.to_not raise_error
      end

      it "should not delete PaymentProfile" do
        payment_profile = FactoryGirl.create(:payment_profile)
        expect {
          delete :destroy, :id => payment_profile.id, :format => 'html'
        }.to_not change(PaymentProfile, :count)
      end
    end
    
    context "as authenticated customer" do
      include_context "with authenticated customer"

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

        # Behavior
        it "should not persist PaymentProfile" do
          expect { payment_profile.reload }.to raise_error
        end

        it "should not delete PaymentProfile" do
          payment_profile = FactoryGirl.create(:payment_profile)
          expect {
            delete :destroy, :id => payment_profile.id, :format => 'html'
          }.to change(PaymentProfile, :count).by(-1)
        end
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

        # Behavior
        it "should persist PaymentProfile" do
          expect { payment_profile.reload }.to_not raise_error
        end

        it "should not delete PaymentProfile" do
          payment_profile = FactoryGirl.create(:payment_profile)
          expect {
            delete :destroy, :id => payment_profile.id, :format => 'html'
          }.to_not change(PaymentProfile, :count)
        end
      end
    end
  end
end