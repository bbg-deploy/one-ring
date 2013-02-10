require 'spec_helper'

describe Customer::PasswordsController do
  include Devise::TestHelpers

  describe "routing", :routing => true do
    let(:customer) { FactoryGirl.create(:customer) }

    it { should route(:get, "/customer/password/new").to(:action => :new) }
    it { should route(:post, "/customer/password").to(:action => :create) }
    it { should route(:get, "/customer/password/edit").to(:action => :edit) }
    it { should route(:put, "/customer/password").to(:action => :update) }
  end

  context "as unconfirmed customer (not logged in)", :unconfirmed => true do
    let(:customer) do
      FactoryGirl.create(:customer)
    end
    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:customer]
      customer.send_reset_password_instructions
      reset_email
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
        it { should redirect_to(new_customer_session_path) }

        # Content
        it { should set_the_flash[:notice].to(/receive an email with instructions about how to reset your password/) }

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
            email.body.should match(/#{customer.reset_password_token}/)
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

    describe "#edit", :edit => true do
      context "with no password reset token" do
        before(:each) do
          get :edit, :format => 'html'
        end
  
        # Response
        it { should_not assign_to(:customer) }
        it { should respond_with(:redirect) }
        it { should redirect_to(new_customer_session_path) }
  
        # Content
        it { should set_the_flash[:error].to(/can't access this page without coming from a password reset email/) }
      end

      context "with invalid password reset token" do
        before(:each) do
          @request.env['QUERY_STRING'] = "reset_password_token="
          get :edit, :reset_password_token => "abcdef", :format => 'html'
        end
  
        # Response
        it { should assign_to(:customer) }
        it { should respond_with(:redirect) }
        it { should redirect_to(new_customer_session_path) }
  
        # Content
        it { should set_the_flash[:alert].to(/reset token is invalid or expired/) }
      end

      context "with valid password reset token" do
        before(:each) do
          reset_email
          @request.env['QUERY_STRING'] = "reset_password_token="
          get :edit, :reset_password_token => "#{customer.reset_password_token}", :format => 'html'
        end
  
        # Response
        it { should assign_to(:customer) }
        it { should respond_with(:success) }
  
        # Content
        it { should_not set_the_flash }
      end
    end

    describe "#update", :update => true do
      before(:each) do
#        @request.env['QUERY_STRING'] = "reset_password_token="
        attributes = {:reset_password_token => "#{customer.reset_password_token}", :password => "newpass", :password_confirmation => "newpass"}
        put :update, :customer => attributes, :format => 'html'
      end

      # Response
      it { should assign_to(:customer) }
      it { should respond_with(:redirect) }
      it { should redirect_to(new_customer_session_path) }

      # Content
      it { should set_the_flash[:notice].to(/password was changed successfully/) }
      
      # Behavior
      it "should change password" do
        
      end      

      it "should send email" do
        
      end      
    end
  end  
end