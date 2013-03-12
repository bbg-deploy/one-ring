require 'spec_helper'

describe Customer::PaymentProfilesController do
  # Controller Shared Methods
  #----------------------------------------------------------------------------
  def do_get_new
    get :new, :format => 'html'
  end

  def do_post_create(attributes)
    post :create, :payment_profile => attributes, :format => 'html'
  end

  def do_get_edit(id)
    get :edit, :id => id, :format => 'html'
  end
  
  def do_put_update(id, attributes)
    put :update, :id => id, :payment_profile => attributes, :format => 'html'
  end

  def do_get_show(id)
    get :show, :id => id, :format => 'html'
  end

  def do_delete_destroy(id)
    delete :destroy, :id => id, :format => 'html'
  end

  # Routing
  #----------------------------------------------------------------------------
  describe "routing", :routing => true do
    it { should route(:get, "/customer/payment_methods").to(:action => :index) }
    it { should route(:get, "/customer/payment_methods/new").to(:action => :new) }
    it { should route(:post, "/customer/payment_methods").to(:action => :create) }
    it { should route(:get, "/customer/payment_methods/1").to(:action => :show, :id => 1) }
    it { should route(:get, "/customer/payment_methods/1/edit").to(:action => :edit, :id => 1) }
    it { should route(:put, "/customer/payment_methods/1").to(:action => :update, :id => 1) }
    it { should route(:delete, "/customer/payment_methods/1").to(:action => :destroy, :id => 1) }
  end

  # Methods
  #----------------------------------------------------------------------------
  describe "#new", :new => true do
    context "as unauthenticated customer" do
      include_context "with unauthenticated customer"
      before(:each) do
        do_get_new
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
        do_get_new
      end

      # Response
      it { should assign_to(:payment_profile) }
      it { should respond_with(:success) }
      it { should render_template("layouts/customer_layout") }

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
      it { should_not assign_to(:payment_profile) }
      it { should respond_with(:redirect) }
      it { should redirect_to(new_customer_session_path) }

      # Content
      it { should set_the_flash[:alert].to(/need to sign in or sign up/) }
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
      it { should_not assign_to(:payment_profile) }
      it { should respond_with(:redirect) }
      it { should redirect_to(new_customer_session_path) }

      # Content
      it { should set_the_flash[:alert].to(/need to sign in or sign up/) }
    end
  end

  describe "#create", :create => true do
    context "as unauthenticated customer" do
      include_context "with unauthenticated customer"

      describe "creating bank account profile" do
        let(:attributes) { FactoryGirl.build(:payment_profile_bank_account_attributes_hash).except(:customer) }
        before(:each) do
          do_post_create(attributes)
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
          do_post_create(attributes)
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
          do_post_create(attributes)
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
          do_post_create(attributes)
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

    context "as authenticated store" do
      include_context "with authenticated store"
      let(:attributes) { FactoryGirl.build(:payment_profile_credit_card_attributes_hash).except(:customer) }

      before(:each) do
        do_post_create(attributes)
      end

      # Variables
      it "should have current store" do
        subject.current_store.should_not be_nil
      end

      # Response
      it { should_not assign_to(:payment_profile) }
      it { should respond_with(:redirect) }
      it { should redirect_to(new_customer_session_path) }

      # Content
      it { should set_the_flash[:alert].to(/need to sign in or sign up/) }
    end

    context "as authenticated employee" do
      include_context "with authenticated employee"
      let(:attributes) { FactoryGirl.build(:payment_profile_credit_card_attributes_hash).except(:customer) }

      before(:each) do
        do_post_create(attributes)
      end

      # Variables
      it "should have current employee" do
        subject.current_employee.should_not be_nil
      end

      # Response
      it { should_not assign_to(:payment_profile) }
      it { should respond_with(:redirect) }
      it { should redirect_to(new_customer_session_path) }

      # Content
      it { should set_the_flash[:alert].to(/need to sign in or sign up/) }
    end
  end

  describe "#show", :show => true do
    context "as unauthenticated customer" do
      include_context "with unauthenticated customer"
      
      let(:payment_profile) { FactoryGirl.create(:payment_profile) }

      before(:each) do
        do_get_show(payment_profile.id)
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

      context "with customer's payment_profile" do
        let(:payment_profile) { FactoryGirl.create(:payment_profile, :customer => customer) }

        before(:each) do
          do_get_show(payment_profile.id)
        end

        # Response
        it { should assign_to(:payment_profile) }
        it { should respond_with(:success) }
        it { should render_template("layouts/customer_layout") }
  
        # Content
        it { should_not set_the_flash }
        it { should render_template(:show) }
      end

      context "with other customer's payment_profile" do
        let(:payment_profile) { FactoryGirl.create(:payment_profile) }

        before(:each) do
          do_get_show(payment_profile.id)
        end

        # Response
        it { should assign_to(:payment_profile) }
        it { should respond_with(:redirect) }
        it { should redirect_to(customer_home_path) }
  
        # Content
        it { should set_the_flash[:alert].to(/Access denied/) }
      end
    end

    context "as authenticated store" do
      include_context "with authenticated store"
      let(:payment_profile) { FactoryGirl.create(:payment_profile) }

      before(:each) do
        do_get_show(payment_profile.id)
      end

      # Variables
      it "should have current store" do
        subject.current_store.should_not be_nil
      end

      # Response
      it { should_not assign_to(:payment_profile) }
      it { should respond_with(:redirect) }
      it { should redirect_to(new_customer_session_path) }

      # Content
      it { should set_the_flash[:alert].to(/need to sign in or sign up/) }
    end

    context "as authenticated employee" do
      include_context "with authenticated employee"
      let(:payment_profile) { FactoryGirl.create(:payment_profile) }

      before(:each) do
        do_get_show(payment_profile.id)
      end

      # Variables
      it "should have current employee" do
        subject.current_employee.should_not be_nil
      end

      # Response
      it { should_not assign_to(:payment_profile) }
      it { should respond_with(:redirect) }
      it { should redirect_to(new_customer_session_path) }

      # Content
      it { should set_the_flash[:alert].to(/need to sign in or sign up/) }
    end
  end

  describe "#edit", :edit => true do
    context "as unauthenticated customer" do
      include_context "with unauthenticated customer"
      
      let(:payment_profile) { FactoryGirl.create(:payment_profile) }
      before(:each) do
        do_get_edit(payment_profile.id)
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
          do_get_edit(payment_profile.id)
        end

        # Response
        it { should assign_to(:payment_profile) }
        it { should respond_with(:success) }
        it { should render_template("layouts/customer_layout") }

        # Content
        it { should_not set_the_flash }
        it { should render_template(:edit) }
      end

      describe "with other customer's payment_profile" do
        let(:payment_profile) { FactoryGirl.create(:payment_profile) }
        before(:each) do
          do_get_edit(payment_profile.id)
        end

        # Response
        it { should assign_to(:payment_profile) }
        it { should respond_with(:redirect) }
        it { should redirect_to(customer_home_path) }
  
        # Content
        it { should set_the_flash[:alert].to(/Access denied/) }
      end
    end

    context "as authenticated store" do
      include_context "with authenticated store"
      let(:payment_profile) { FactoryGirl.create(:payment_profile) }

      before(:each) do
        do_get_edit(payment_profile.id)
      end

      # Variables
      it "should have current store" do
        subject.current_store.should_not be_nil
      end

      # Response
      it { should_not assign_to(:payment_profile) }
      it { should respond_with(:redirect) }
      it { should redirect_to(new_customer_session_path) }

      # Content
      it { should set_the_flash[:alert].to(/need to sign in or sign up/) }
    end

    context "as authenticated employee" do
      include_context "with authenticated employee"
      let(:payment_profile) { FactoryGirl.create(:payment_profile) }

      before(:each) do
        do_get_edit(payment_profile.id)
      end

      # Variables
      it "should have current employee" do
        subject.current_employee.should_not be_nil
      end

      # Response
      it { should_not assign_to(:payment_profile) }
      it { should respond_with(:redirect) }
      it { should redirect_to(new_customer_session_path) }

      # Content
      it { should set_the_flash[:alert].to(/need to sign in or sign up/) }
    end
  end

  describe "#update", :update => true do
    context "as unauthenticated customer" do
      include_context "with unauthenticated customer"
      let(:payment_profile) { FactoryGirl.create(:payment_profile) }
      let(:attributes) { { :first_name => "Billy" } }

      before(:each) do
        do_put_update(payment_profile.id, attributes)
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

      context "with customer's payment_profile" do
        let(:payment_profile) { FactoryGirl.create(:payment_profile, :customer => customer) }
        let(:attributes) { { :first_name => "Billy" } }

        before(:each) do
          do_put_update(payment_profile.id, attributes)
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

      context "with other customer's payment_profile" do
        let(:payment_profile) { FactoryGirl.create(:payment_profile) }
        let(:attributes) { { :first_name => "Billy" } }

        before(:each) do
          do_put_update(payment_profile.id, attributes)
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

    context "as authenticated store" do
      include_context "with authenticated store"
      let(:payment_profile) { FactoryGirl.create(:payment_profile) }
      let(:attributes) { { :first_name => "Billy" } }

      before(:each) do
        do_put_update(payment_profile.id, attributes)
      end

      # Variables
      it "should have current store" do
        subject.current_store.should_not be_nil
      end

      # Response
      it { should_not assign_to(:payment_profile) }
      it { should respond_with(:redirect) }
      it { should redirect_to(new_customer_session_path) }

      # Content
      it { should set_the_flash[:alert].to(/need to sign in or sign up/) }
    end

    context "as authenticated employee" do
      include_context "with authenticated employee"
      let(:payment_profile) { FactoryGirl.create(:payment_profile) }
      let(:attributes) { { :first_name => "Billy" } }

      before(:each) do
        do_put_update(payment_profile.id, attributes)
      end

      # Variables
      it "should have current employee" do
        subject.current_employee.should_not be_nil
      end

      # Response
      it { should_not assign_to(:payment_profile) }
      it { should respond_with(:redirect) }
      it { should redirect_to(new_customer_session_path) }

      # Content
      it { should set_the_flash[:alert].to(/need to sign in or sign up/) }
    end
  end

  describe "#destroy", :destroy => true do
    context "as unauthenticated customer" do
      include_context "with unauthenticated customer"
      let(:payment_profile) { FactoryGirl.create(:payment_profile) }

      before(:each) do
        do_delete_destroy(payment_profile.id)
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
        PaymentProfile.last.should eq(payment_profile)
      end
    end
    
    context "as authenticated customer" do
      include_context "with authenticated customer"

      context "with customer's payment_profile" do
        let(:payment_profile) { FactoryGirl.create(:payment_profile, :customer => customer) }

        before(:each) do
          do_delete_destroy(payment_profile.id)
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

        it "should delete PaymentProfile" do
          PaymentProfile.last.should_not eq(payment_profile)
        end
      end

      context "with other customer's payment_profile" do
        let(:payment_profile) { FactoryGirl.create(:payment_profile) }

        before(:each) do
          do_delete_destroy(payment_profile.id)
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
          PaymentProfile.last.should eq(payment_profile)
        end
      end
    end

    context "as authenticated store" do
      include_context "with authenticated store"
      let(:payment_profile) { FactoryGirl.create(:payment_profile) }

      before(:each) do
        do_delete_destroy(payment_profile.id)
      end

      # Variables
      it "should have current store" do
        subject.current_store.should_not be_nil
      end

      # Response
      it { should_not assign_to(:payment_profile) }
      it { should respond_with(:redirect) }
      it { should redirect_to(new_customer_session_path) }

      # Content
      it { should set_the_flash[:alert].to(/need to sign in or sign up/) }
    end

    context "as authenticated employee" do
      include_context "with authenticated employee"
      let(:payment_profile) { FactoryGirl.create(:payment_profile) }

      before(:each) do
        do_delete_destroy(payment_profile.id)
      end

      # Variables
      it "should have current employee" do
        subject.current_employee.should_not be_nil
      end

      # Response
      it { should_not assign_to(:payment_profile) }
      it { should respond_with(:redirect) }
      it { should redirect_to(new_customer_session_path) }

      # Content
      it { should set_the_flash[:alert].to(/need to sign in or sign up/) }
    end
  end
end