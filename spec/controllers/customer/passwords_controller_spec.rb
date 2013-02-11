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

  describe "#new", :new => true do
    context "as unauthenticated customer" do
      include_context "as unauthenticated customer"
      before(:each) do
        get :new, :format => 'html'
      end

      it "should not have customer" do
        subject.try(:current_customer).should be_nil
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
      
      it "should have customer" do
        subject.try(:current_customer).should_not be_nil
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
    context "as unauthenticated customer" do
      include_context "as unauthenticated customer"

      context "with mismatched email" do
        before(:each) do
          attributes = {:email => "fake@fakemail.com"}
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
        it "did not send confirmation email" do
          last_email.should be_nil
        end
      end
      
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
        it "sent confirmation email" do
          last_email.should_not be_nil
          last_email.to.should eq([customer.email])
          last_email.body.should match(/#{customer.reset_password_token}/)
        end
      end
    end

    context "as authenticated customer" do
      include_context "as authenticated customer"
      before(:each) do
        attributes = {:email => customer.email}
        post :create, :customer => attributes, :format => 'html'
      end
      
      it "should have customer" do
        subject.try(:current_customer).should_not be_nil
      end

      # Response
      it { should_not assign_to(:customer) }
      it { should respond_with(:redirect) }
      it { should redirect_to(customer_home_path) }

      # Content
      it { should set_the_flash[:alert].to(/already signed in/) }      
    end
  end

  describe "#edit", :edit => true do
    context "as unauthenticated customer" do
      context "without password reset requested" do
        include_context "as unauthenticated customer"

        describe "no password reset token" do
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

        describe "with invalid password reset token" do
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
      end      

      context "with password reset requested" do
        include_context "as unauthenticated customer with password reset request"

        describe "no password reset token" do
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

        describe "with invalid password reset token" do
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

        describe "valid password reset token" do
          before(:each) do
            @request.env['QUERY_STRING'] = "reset_password_token="
            get :edit, :reset_password_token => "#{customer.reset_password_token}", :format => 'html'
          end
    
          # Response
          it { should assign_to(:customer) }
          it { should respond_with(:success) }
    
          # Content
          it { should_not set_the_flash }
          it { should render_template(:edit) }
        end
      end      
    end

    context "as authenticated customer" do
      include_context "as authenticated customer"
      before(:each) do
        get :edit, :format => 'html'
      end
      
      it "should have customer" do
        subject.try(:current_customer).should_not be_nil
      end

      # Response
      it { should_not assign_to(:customer) }
      it { should respond_with(:redirect) }
      it { should redirect_to(customer_home_path) }

      # Content
      it { should set_the_flash[:alert].to(/already signed in/) }      
    end
  end

  describe "#update", :update => true do
    context "as unauthenticated, unconfirmed customer" do
      context "without password reset requested" do
        include_context "as unauthenticated, unconfirmed customer"

        describe "with no password reset token" do
          before(:each) do
            attributes = {:password => "newpass", :password_confirmation => "newpass"}
            put :update, :customer => attributes, :format => 'html'
          end
          
          # Response
          it { should assign_to(:customer) }
          it { should respond_with(:success) }
    
          # Content
          it { should_not set_the_flash }
          it { should render_template(:edit) }
        end

        describe "with invalid password reset token" do
          before(:each) do
            attributes = {:reset_password_token => "#abcdef", :password => "newpass", :password_confirmation => "newpass"}
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

      context "with password reset requested" do
        include_context "as unauthenticated, unconfirmed customer with password reset request"
        
        describe "with no password reset token" do
          before(:each) do
            attributes = {:password => "newpass", :password_confirmation => "newpass"}
            put :update, :customer => attributes, :format => 'html'
          end
          
          # Response
          it { should assign_to(:customer) }
          it { should respond_with(:success) }
    
          # Content
          it { should_not set_the_flash }
          it { should render_template(:edit) }
        end
       
        describe "with invalid password reset token" do
          before(:each) do
            attributes = {:reset_password_token => "#abcdef", :password => "newpass", :password_confirmation => "newpass"}
            put :update, :customer => attributes, :format => 'html'
          end
    
          # Response
          it { should assign_to(:customer) }
          it { should respond_with(:success) }
    
          # Content
          it { should_not set_the_flash }
          it { should render_template(:edit) }
        end

        describe "with valid password reset token" do
          before(:each) do
            attributes = {:reset_password_token => "#{customer.reset_password_token}", :password => "newpass", :password_confirmation => "newpass"}
            put :update, :customer => attributes, :format => 'html'
          end
      
          # Response
          it { should assign_to(:customer) }
          it { should respond_with(:redirect) }
          # Should go to sign-in page instead of customer home because the account is not confirmed
          it { should redirect_to(new_customer_session_path) }
      
          # Content
          it { should set_the_flash[:notice].to(/password was changed successfully/) }
          it { should set_the_flash[:alert].to(/have to confirm your account/) }
            
          # Behavior
          it "should change password" do
            original_pass = customer.encrypted_password
            customer.reload
            customer.encrypted_password.should_not eq(original_pass)
          end    
        end        
      end
    end

    context "as unauthenticated, confirmed customer" do
      context "without password reset requested" do
        include_context "as unauthenticated customer"

        describe "with no password reset token" do
          before(:each) do
            attributes = {:password => "newpass", :password_confirmation => "newpass"}
            put :update, :customer => attributes, :format => 'html'
          end
          
          # Response
          it { should assign_to(:customer) }
          it { should respond_with(:success) }
    
          # Content
          it { should_not set_the_flash }
          it { should render_template(:edit) }
        end

        describe "with invalid password reset token" do
          before(:each) do
            attributes = {:reset_password_token => "#abcdef", :password => "newpass", :password_confirmation => "newpass"}
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

      context "with password reset requested" do
        include_context "as unauthenticated customer with password reset request"

        describe "with no password reset token" do
          before(:each) do
            attributes = {:password => "newpass", :password_confirmation => "newpass"}
            put :update, :customer => attributes, :format => 'html'
          end
          
          # Response
          it { should assign_to(:customer) }
          it { should respond_with(:success) }
    
          # Content
          it { should_not set_the_flash }
          it { should render_template(:edit) }
        end
       
        describe "with invalid password reset token" do
          before(:each) do
            attributes = {:reset_password_token => "#abcdef", :password => "newpass", :password_confirmation => "newpass"}
            put :update, :customer => attributes, :format => 'html'
          end
    
          # Response
          it { should assign_to(:customer) }
          it { should respond_with(:success) }
    
          # Content
          it { should_not set_the_flash }
          it { should render_template(:edit) }
        end

        describe "with valid password reset token" do
          before(:each) do
            attributes = {:reset_password_token => "#{customer.reset_password_token}", :password => "newpass", :password_confirmation => "newpass"}
            put :update, :customer => attributes, :format => 'html'
          end
      
          # Response
          it { should assign_to(:customer) }
          it { should respond_with(:redirect) }
          it { should redirect_to(customer_home_path) }
      
          # Content
          it { should set_the_flash[:notice].to(/password was changed successfully. You are now signed in/) }
            
          # Behavior
          it "should change password" do
            original_pass = customer.encrypted_password
            customer.reload
            customer.encrypted_password.should_not eq(original_pass)
          end    
        end        
      end
    end

    context "as authenticated customer" do
      include_context "as authenticated customer"
      before(:each) do
        attributes = {:password => "newpass", :password_confirmation => "newpass"}
        put :update, :customer => attributes, :format => 'html'
      end
      
      it "should have customer" do
        subject.try(:current_customer).should_not be_nil
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