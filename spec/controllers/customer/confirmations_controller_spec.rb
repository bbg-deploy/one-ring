require 'spec_helper'

describe Customer::ConfirmationsController do
  include Devise::TestHelpers

  describe "routing", :routing => true do
    let(:customer) { FactoryGirl.create(:customer) }

    it { should route(:get, "/customer/confirmation/new").to(:action => :new) }
    it { should route(:post, "/customer/confirmation").to(:action => :create) }
    it { should route(:get, "/customer/confirmation").to(:action => :show) }
  end

  describe "#new", :new => true do
    context "as unauthenticated customer" do
      include_context "as unauthenticated customer"
      before(:each) do
        get :new, :format => 'html'
      end

      # Response
      it { should assign_to(:customer) }
      it { should respond_with(:success) }

      # Content
      it { should_not set_the_flash }
      it { should render_template(:new) }
    end

    context "as authenticated customer" do
      include_context "as authenticated customer"
      before(:each) do
        get :new, :format => 'html'
      end

      # Response
      it { should_not assign_to(:customer) }
      it { should respond_with(:redirect) }
      it { should redirect_to(customer_home_path) }

      # Content
      it { should set_the_flash[:alert].to(/already signed in/) }
    end
  end

  describe "#create", :create => true do
    context "as unauthenticated, unconfirmed customer" do
      include_context "as unauthenticated, unconfirmed customer"

      describe "with invalid email" do
        before(:each) do
          attributes = {:email => "fake@email.com"}
          post :create, :customer => attributes, :format => 'html'
        end

        # Parameters
#       it { should permit(:email).for(:create) }

        # Response
        it { should assign_to(:customer) }
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
          attributes = {:email => customer.email}
          post :create, :customer => attributes, :format => 'html'
        end

        # Parameters
#       it { should permit(:email).for(:create) }

        # Response
        it { should assign_to(:customer) }
        it { should respond_with(:redirect) }
        it { should redirect_to(home_path) }

        # Content
        it { should set_the_flash[:notice].to(/email with instructions about how to confirm/) }

        # Behavior
        it "should send confirmation email" do
          last_email.should_not be_nil
          last_email.to.should eq([customer.email])
          last_email.body.should match(/#{customer.confirmation_token}/)
        end
      end
    end

    context "as unauthenticated, confirmed customer" do
      include_context "as unauthenticated customer"

      describe "with valid email" do
        before(:each) do
          reset_email
          attributes = {:email => customer.email}
          post :create, :customer => attributes, :format => 'html'
        end

        # Parameters
#       it { should permit(:email).for(:create) }

        # Response
        it { should assign_to(:customer) }
        it { should respond_with(:success) }

        # Content
        it { should render_template(:new) }

        # Behavior
        it "should not send email" do
          last_email.should be_nil
        end
      end
    end
    
    context "as authenticated customer" do
      include_context "as authenticated customer"

      describe "with valid email" do
        before(:each) do
          attributes = {:email => customer.email}
          post :create, :customer => attributes, :format => 'html'
        end
  
        # Parameters
  #       it { should permit(:email).for(:create) }
  
        # Response
        it { should_not assign_to(:customer) }
        it { should respond_with(:redirect) }
        it { should redirect_to(customer_home_path) }
  
        # Content
        it { should set_the_flash[:alert].to(/already signed in/) }
      end
    end
  end

  describe "#show", :show => true do
    context "as unauthenticated, unconfirmed customer" do
      include_context "as unauthenticated, unconfirmed customer"
      
      describe "with invalid token" do
        before(:each) do
          @request.env['QUERY_STRING'] = "confirmation_token="
          get :show, :confirmation_token => "1234234234", :format => 'html'
        end

        # Response
        it { should assign_to(:customer) }
        it { should respond_with(:success) }

        # Content
        it { should_not set_the_flash }
        it { should render_template(:new) }
      end

      describe "with valid token" do
        before(:each) do
          @request.env['QUERY_STRING'] = "confirmation_token="
          get :show, :confirmation_token => "#{customer.confirmation_token}", :format => 'html'
        end        

        # Response
        it { should assign_to(:customer) }
        it { should redirect_to(customer_home_path) }
  
        # Content
        it { should set_the_flash[:notice].to(/successfully confirmed/) }
      end
    end
    
    context "as authenticated customer" do
      include_context "as authenticated customer"

      describe "with valid token" do
        before(:each) do
          @request.env['QUERY_STRING'] = "confirmation_token="
          get :show, :confirmation_token => "#{customer.confirmation_token}", :format => 'html'
        end        

        # Response
        it { should_not assign_to(:customer) }
        it { should redirect_to(customer_home_path) }
  
        # Content
        it { should set_the_flash[:alert].to(/already signed in/) }
      end
    end
  end
end