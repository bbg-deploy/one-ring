require 'spec_helper'

describe Customer::ConfirmationsController do
  include Devise::TestHelpers

  describe "routing", :routing => true do
    let(:customer) { FactoryGirl.create(:customer) }

    it { should route(:get, "/customer/confirmation/new").to(:action => :new) }
    it { should route(:post, "/customer/confirmation").to(:action => :create) }
    it { should route(:get, "/customer/confirmation").to(:action => :show) }
  end

  context "as unconfirmed customer (not logged in)", :unconfirmed => true do
    let(:customer) do
      FactoryGirl.create(:customer)
    end
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
      context "with matching email" do
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
        describe "confirmation email" do
          let(:email) { ActionMailer::Base::deliveries.last }

          it "should not be nil" do
            email.should_not be_nil
          end

          it "should be sent to customer" do
            email.to.should eq([customer.email])
          end

          it "should have confirmation link in body" do
            email.body.should match(/#{customer.confirmation_token}/)
          end
        end
      end
      
      context "with invalid email" do
        before(:each) do
          attributes = {:email => "invalid@email.com"}
          post :create, :customer => attributes, :format => 'html'
        end

        # Parameters
#       it { should permit(:email).for(:create) }

        # Response
        it { should assign_to(:customer) }
        it { should respond_with(:success) }

        # Content
        it { should_not set_the_flash }

        # Behavior
        describe "confirmation email" do
          let(:email) { ActionMailer::Base::deliveries.last }

          it "should be nil" do
            email.should be_nil
          end
        end
      end
    end

    describe "#show", :show => true do
      context "with invalid confirmation token" do
        before(:each) do
          @request.env['QUERY_STRING'] = "confirmation_token="
          get :show, :confirmation_token => "1234234234", :format => 'html'
        end

        # Response
        it { should assign_to(:customer) }
        it { should respond_with(:success) }

        # Content
        it { should_not set_the_flash }        
      end

      context "with valid confirmation token" do
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
  end
  
  context "as confirmed customer (not logged in)", :confirmed => true do
    let(:customer) do
      FactoryGirl.create(:customer)
    end
    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:customer]
      customer.confirm!
      reset_email
    end

    it "does not have a current customer" do
      subject.current_customer.should be_nil
    end
    
    it "is a confirmed customer" do
      customer.confirmed?.should be_true
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
      context "with matching email" do
        before(:each) do
          attributes = {:email => customer.email}
          post :create, :customer => attributes, :format => 'html'
        end

        # Parameters
#       it { should permit(:email).for(:create) }

        # Response
        it { should assign_to(:customer) }
        it { should respond_with(:success) }

        # Content
        it { should_not set_the_flash }

        # Behavior
        describe "confirmation email" do
          let(:email) { ActionMailer::Base::deliveries.last }

          it "should be nil" do
            email.should be_nil
          end
        end
      end
      
      context "with invalid email" do
        before(:each) do
          attributes = {:email => "invalid@email.com"}
          post :create, :customer => attributes, :format => 'html'
        end

        # Parameters
#       it { should permit(:email).for(:create) }

        # Response
        it { should assign_to(:customer) }
        it { should respond_with(:success) }

        # Content
        it { should_not set_the_flash }

        # Behavior
        describe "confirmation email" do
          let(:email) { ActionMailer::Base::deliveries.last }

          it "should be nil" do
            email.should be_nil
          end
        end
      end
    end

    describe "#show", :show => true do
      context "with invalid confirmation token" do
        before(:each) do
          @request.env['QUERY_STRING'] = "confirmation_token="
          get :show, :confirmation_token => "1234234234", :format => 'html'
        end

        # Response
        it { should assign_to(:customer) }
        it { should respond_with(:success) }

        # Content
        it { should_not set_the_flash }        
      end

      context "with valid confirmation token" do
        before(:each) do
          @request.env['QUERY_STRING'] = "confirmation_token="
          get :show, :confirmation_token => "#{customer.confirmation_token}", :format => 'html'
        end        
        # Response
        it { should assign_to(:customer) }
        it { should respond_with(:success) }

        # Content
        it { should_not set_the_flash }        
      end
    end
  end
  
  context "as authenticated customer", :authenticated => true do
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
      it { should respond_with(:redirect) }
      it { should redirect_to(customer_home_path) }

      # Content
      it { should set_the_flash[:alert].to(/already signed in/) }
    end

    describe "#create", :create => true do
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

    describe "#show", :show => true do
      context "with invalid confirmation token" do
        before(:each) do
          @request.env['QUERY_STRING'] = "confirmation_token="
          get :show, :confirmation_token => "1234234234", :format => 'html'
        end

        # Response
        it { should_not assign_to(:customer) }
        it { should respond_with(:redirect) }
        it { should redirect_to(customer_home_path) }

        # Content
        it { should set_the_flash[:alert].to(/already signed in/) }
      end

      context "with valid confirmation token" do
        before(:each) do
          @request.env['QUERY_STRING'] = "confirmation_token="
          get :show, :confirmation_token => "#{customer.confirmation_token}", :format => 'html'
        end        
        # Response
        it { should_not assign_to(:customer) }
        it { should respond_with(:redirect) }
        it { should redirect_to(customer_home_path) }

        # Content
        it { should set_the_flash[:alert].to(/already signed in/) }
      end
    end
  end
end