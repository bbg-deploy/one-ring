require 'spec_helper'

describe Customer::PaymentsController do
  # Controller Shared Methods
  #----------------------------------------------------------------------------
  def do_get_index
    get :index, :format => 'html'
  end

  def do_get_new
    get :new, :format => 'html'
  end

  def do_post_create(attributes)
    post :create, :payment => attributes, :format => 'html'
  end

  # Routing
  #----------------------------------------------------------------------------
  describe "routing", :routing => true do
    it { should route(:get, "/customer/payments").to(:action => :index) }
    it { should route(:get, "/customer/payments/new").to(:action => :new) }
    it { should route(:post, "/customer/payments").to(:action => :create) }
  end

  # Methods
  #----------------------------------------------------------------------------
  describe "#index", :index => true do
    context "as unauthenticated customer" do
      include_context "with unauthenticated customer"

      before(:each) do
        do_get_index
      end

      # Response
      it { should_not assign_to(:payments) }
      it { should respond_with(:redirect) }
      it { should redirect_to(new_customer_session_path) }

      # Content
      it { should set_the_flash[:alert].to(/need to sign in or sign up/) }      
    end

    context "as authenticated customer" do
      include_context "with authenticated customer"
      let(:payment_profile) { FactoryGirl.create(:payment_profile, :customer => customer) }
      let(:payment_1) { FactoryGirl.create(:payment) }
      let(:payment_2) { FactoryGirl.create(:payment) }
      let(:payment_3) { FactoryGirl.create(:payment, :customer => customer, :payment_profile => payment_profile) }
      let(:payment_4) { FactoryGirl.create(:payment, :customer => customer, :payment_profile => payment_profile) }

      before(:each) do
        do_get_index
      end

      # Response
      it { should assign_to(:payments).with([payment_3, payment_4]) }

      it { should respond_with(:success) }
      it { should render_template("layouts/customer_layout") }

      # Content
      it { should_not set_the_flash }
      it { should render_template(:index) }
      
      # Behavior
    end

    context "as authenticated store" do
      include_context "with authenticated store"

      before(:each) do
        do_get_index
      end

      # Variables
      it "should have current store" do
        subject.current_store.should_not be_nil
      end

      # Response
      it { should_not assign_to(:payments) }
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
      it { should_not assign_to(:payments) }
      it { should respond_with(:redirect) }
      it { should redirect_to(new_customer_session_path) }

      # Content
      it { should set_the_flash[:alert].to(/need to sign in or sign up/) }
    end
  end

  describe "#new", :new => true do
    context "as unauthenticated customer" do
      include_context "with unauthenticated customer"
      before(:each) do
        do_get_new
      end

      # Response
      it { should_not assign_to(:payment) }
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
      it { should assign_to(:payment).with_kind_of(Payment) }
      it { should respond_with(:success) }
      it { should render_template("layouts/customer_layout") }

      # Content
      it { should_not set_the_flash }
      it { should render_template(:new) }
    end

    context "as authenticated store" do
      include_context "with authenticated store"

      before(:each) do
        do_get_index
      end

      # Variables
      it "should have current store" do
        subject.current_store.should_not be_nil
      end

      # Response
      it { should_not assign_to(:payment) }
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
      it { should_not assign_to(:payment) }
      it { should respond_with(:redirect) }
      it { should redirect_to(new_customer_session_path) }

      # Content
      it { should set_the_flash[:alert].to(/need to sign in or sign up/) }
    end
  end

  describe "#create", :create => true do
    context "as unauthenticated customer" do
      include_context "with unauthenticated customer"
      let(:payment_profile) { FactoryGirl.create(:payment_profile, :customer => customer)}
      let(:attributes) { FactoryGirl.build(:payment_attributes_hash, :payment_profile => payment_profile.id).except(:customer) }
      before(:each) do
        do_post_create(attributes)
      end

      # Response
      it { should_not assign_to(:payment) }
      it { should respond_with(:redirect) }
      it { should redirect_to(new_customer_session_path) }

      # Content
      it { should set_the_flash[:alert].to(/need to sign in or sign up/) }

      # Behavior
      it "should not create new PaymentProfile" do
        Payment.count.should eq(0)
      end
    end

    context "as authenticated customer" do
      include_context "with authenticated customer"

      context "with invalid attributes" do
        let(:payment_profile) { FactoryGirl.create(:payment_profile, :customer => customer) }
        let(:attributes) { FactoryGirl.build(:payment_attributes_hash, :payment_profile_id => payment_profile.id, :amount => BigDecimal.new("0")).except(:customer) }

        before(:each) do
          do_post_create(attributes)
        end
  
        # Response
        it { should assign_to(:payment).with_kind_of(Payment) }
        it { should respond_with(:success) }
  
        # Content
        it { should set_the_flash[:alert].to(/problem with some of your information/) }
        it { should render_template(:new) }

        # Behavior
        it "should not create new PaymentProfile" do
          Payment.count.should eq(0)
        end
      end

      context "with valid attributes" do
        let(:payment_profile) { FactoryGirl.create(:payment_profile, :customer => customer) }
        let(:attributes) { FactoryGirl.build(:payment_attributes_hash, :payment_profile_id => payment_profile.id).except(:customer) }
        before(:each) do
          do_post_create(attributes)
        end
  
        # Response
        it { should assign_to(:payment).with(Payment.last) }
        it { should respond_with(:redirect) }
        it { should redirect_to(customer_payments_path) }
  
        # Content
        it { should set_the_flash[:notice].to(/Successfully created payment/) }

        # Behavior
        it "should create new PaymentProfile" do
          Payment.count.should eq(1)
        end
      end
    end

    context "as authenticated store" do
      include_context "with authenticated store"

      before(:each) do
        do_get_index
      end

      # Variables
      it "should have current store" do
        subject.current_store.should_not be_nil
      end

      # Response
      it { should_not assign_to(:payment) }
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
      it { should_not assign_to(:payment) }
      it { should respond_with(:redirect) }
      it { should redirect_to(new_customer_session_path) }

      # Content
      it { should set_the_flash[:alert].to(/need to sign in or sign up/) }
    end
  end
end