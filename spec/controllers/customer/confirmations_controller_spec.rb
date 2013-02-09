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
  

  context "as confirmed authenticated customer", :authenticated => true do
    let(:customer) do
      FactoryGirl.create(:customer)
    end
    before(:each) do
      customer.confirm!
      @request.env["devise.mapping"] = Devise.mappings[:customer]
      sign_in customer
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