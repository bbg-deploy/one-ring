require 'spec_helper'

describe Customer::PasswordsController do
  # Controller Shared Methods
  #----------------------------------------------------------------------------
  def do_get_new
    @request.env["devise.mapping"] = Devise.mappings[:customer]
    get :new, :format => 'html'
  end

  def do_post_create(attributes)
    @request.env["devise.mapping"] = Devise.mappings[:customer]
    post :create, :customer => attributes, :format => 'html'
  end

  def do_get_edit(token)
    @request.env["devise.mapping"] = Devise.mappings[:customer]
    @request.env['QUERY_STRING'] = "reset_password_token="
    get :edit, :reset_password_token => token, :format => 'html'
  end
  
  def do_put_update(attributes)
    @request.env["devise.mapping"] = Devise.mappings[:customer]
    put :update, :customer => attributes, :format => 'html'
  end

  def do_get_show(token)
    @request.env["devise.mapping"] = Devise.mappings[:customer]
    @request.env['QUERY_STRING'] = "confirmation_token="
    get :show, :confirmation_token => token, :format => 'html'
  end

  # Routing
  #----------------------------------------------------------------------------
  describe "routing", :routing => true do
    it { should route(:get, "/customer/password/new").to(:action => :new) }
    it { should route(:post, "/customer/password").to(:action => :create) }
    it { should route(:get, "/customer/password/edit").to(:action => :edit) }
    it { should route(:put, "/customer/password").to(:action => :update) }
  end

  # Methods
  #----------------------------------------------------------------------------
  describe "#new", :new => true do
    context "as unauthenticated customer" do
      include_context "with unauthenticated customer"

      before(:each) do
        do_get_new
      end

      # Variables
      it "should not have current user" do
        subject.current_user.should be_nil
      end

      # Response
      it { should assign_to(:customer) }
      it { should respond_with(:success) }

      # Content
      it { should_not set_the_flash }
      it { should render_template(:new) }
    end

    context "as authenticated customer" do
      include_context "with authenticated customer"

      before(:each) do
        do_get_new
      end
      
      # Variables
      it "should have current customer" do
        subject.current_customer.should_not be_nil
      end

      # Response
      it { should_not assign_to(:customer) }
      it { should respond_with(:redirect) }
      it { should redirect_to(customer_home_path) }

      # Content
      it { should set_the_flash[:alert].to(/already signed in/) }      
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
      it { should_not assign_to(:customer) }
      it { should respond_with(:redirect) }
      it { should redirect_to(customer_scope_conflict_path) }

      # Content
      it { should_not set_the_flash }
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
      it { should_not assign_to(:customer) }
      it { should respond_with(:redirect) }
      it { should redirect_to(customer_scope_conflict_path) }

      # Content
      it { should_not set_the_flash }
    end
  end

  describe "#create", :create => true do
    context "as unauthenticated customer" do
      include_context "with unauthenticated customer"

      context "with mismatched email" do
        let(:attributes) { { :email => "mismatch@email.com" } }

        before(:each) do
          do_post_create(attributes)
        end

        # Parameters
#       it { should permit(:email).for(:create) }

        # Variables
        it "should not have current user" do
          subject.current_customer.should be_nil
        end

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
        let(:attributes) { { :email => customer.email } }

        before(:each) do
          do_post_create(attributes)
        end
        
        # Parameters
#       it { should permit(:email).for(:create) }

        # Variables
        it "should not have current user" do
          subject.current_user.should be_nil
        end

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
      include_context "with authenticated customer"
      let(:attributes) { { :email => customer.email } }

      before(:each) do
        do_post_create(attributes)
      end
      
      # Variables
      it "should have current customer" do
        subject.current_customer.should_not be_nil
      end

      # Response
      it { should_not assign_to(:customer) }
      it { should respond_with(:redirect) }
      it { should redirect_to(customer_home_path) }

      # Content
      it { should set_the_flash[:alert].to(/already signed in/) }      
    end

    context "as authenticated store" do
      include_context "with authenticated store"
      let(:customer) { FactoryGirl.create(:customer) }
      let(:attributes) { { :email => customer.email } }

      before(:each) do
        do_post_create(attributes)
      end

      # Variables
      it "should have current store" do
        subject.current_store.should_not be_nil
      end

      # Response
      it { should_not assign_to(:customer) }
      it { should respond_with(:redirect) }
      it { should redirect_to(customer_scope_conflict_path) }

      # Content
      it { should_not set_the_flash }
    end

    context "as authenticated employee" do
      include_context "with authenticated employee"
      let(:customer) { FactoryGirl.create(:customer) }
      let(:attributes) { { :email => customer.email } }

      before(:each) do
        do_post_create(attributes)
      end

      # Variables
      it "should have current employee" do
        subject.current_employee.should_not be_nil
      end

      # Response
      it { should_not assign_to(:customer) }
      it { should respond_with(:redirect) }
      it { should redirect_to(customer_scope_conflict_path) }

      # Content
      it { should_not set_the_flash }
    end
  end

  describe "#edit", :edit => true do
    context "as unauthenticated customer" do
      include_context "with unauthenticated customer"

      context "without password reset requested" do
        context "without password reset token" do

          before(:each) do
            do_get_edit(nil)
          end
          
          # Variables
          it "should not have current user" do
            subject.current_user.should be_nil
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
            do_get_edit("abcdef")
          end
    
          # Variables
          it "should not have current user" do
            subject.current_user.should be_nil
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
        before(:each) do
          customer.send_reset_password_instructions
          reset_email
          customer.reload
        end

        context "without password reset token" do
          before(:each) do
            do_get_edit(nil)
          end
          
          # Variables
          it "should not have current user" do
            subject.current_user.should be_nil
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
            do_get_edit("abcdef")
          end
    
          # Variables
          it "should not have current user" do
            subject.current_user.should be_nil
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
            do_get_edit("#{customer.reset_password_token}")
          end
    
          # Variables
          it "should not have current user" do
            subject.current_user.should be_nil
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
      include_context "with authenticated customer"

      before(:each) do
        do_get_edit("abcdef")
      end
      
      # Variables
      it "should have current customer" do
        subject.current_customer.should_not be_nil
      end

      # Response
      it { should_not assign_to(:customer) }
      it { should respond_with(:redirect) }
      it { should redirect_to(customer_home_path) }

      # Content
      it { should set_the_flash[:alert].to(/already signed in/) }      
    end

    context "as authenticated store" do
      include_context "with authenticated store"
      before(:each) do
        do_get_edit("abcdef")
      end

      # Variables
      it "should have current store" do
        subject.current_store.should_not be_nil
      end

      # Response
      it { should_not assign_to(:customer) }
      it { should respond_with(:redirect) }
      it { should redirect_to(customer_scope_conflict_path) }

      # Content
      it { should_not set_the_flash }
    end

    context "as authenticated employee" do
      include_context "with authenticated employee"
      before(:each) do
        do_get_edit("abcdef")
      end

      # Variables
      it "should have current employee" do
        subject.current_employee.should_not be_nil
      end

      # Response
      it { should_not assign_to(:customer) }
      it { should respond_with(:redirect) }
      it { should redirect_to(customer_scope_conflict_path) }

      # Content
      it { should_not set_the_flash }
    end
  end

  describe "#update", :update => true do
    context "as unconfirmed customer" do
      include_context "with unconfirmed customer"

      context "without password reset requested" do
        context "without password reset token" do
          let(:attributes) { {:password => "newpass", :password_confirmation => "newpass"} }

          before(:each) do
            do_put_update(attributes)
          end
          
          # Variables
          it "should not have current user" do
            subject.current_user.should be_nil
          end
    
          # Response
          it { should assign_to(:customer) }
          it { should respond_with(:success) }
    
          # Content
          it { should_not set_the_flash }
          it { should render_template(:edit) }
        end

        context "with invalid password reset token" do
          let(:attributes) { { :reset_password_token => "#abcdef", :password => "newpass", :password_confirmation => "newpass" } }

          before(:each) do
            do_put_update(attributes)
          end
    
          # Variables
          it "should not have current user" do
            subject.current_user.should be_nil
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
        before(:each) do
          customer.send_reset_password_instructions
          reset_email
          customer.reload
        end
        
        context "without password reset token" do
          let(:attributes) { { :password => "newpass", :password_confirmation => "newpass" } }

          before(:each) do
            do_put_update(attributes)
          end
          
          # Variables
          it "should not have current user" do
            subject.current_user.should be_nil
          end

          # Response
          it { should assign_to(:customer) }
          it { should respond_with(:success) }
    
          # Content
          it { should_not set_the_flash }
          it { should render_template(:edit) }
        end
       
        context "with invalid password reset token" do
          let(:attributes) { { :reset_password_token => "#abcdef", :password => "newpass", :password_confirmation => "newpass" } }

          before(:each) do
            do_put_update(attributes)
          end
    
          # Variables
          it "should not have current user" do
            subject.current_user.should be_nil
          end

          # Response
          it { should assign_to(:customer) }
          it { should respond_with(:success) }
    
          # Content
          it { should_not set_the_flash }
          it { should render_template(:edit) }
        end

        context "with valid password reset token" do
          let(:attributes) { { :reset_password_token => "#{customer.reset_password_token}", :password => "newpass", :password_confirmation => "newpass" } }

          before(:each) do
            do_put_update(attributes)
          end
      
          # Variables
          it "should not have current user" do
            subject.current_user.should be_nil
          end

          # Response
          it { should assign_to(:customer) }
          it { should respond_with(:redirect) }
          it { should redirect_to(new_customer_session_path) } # Should go to sign-in page instead of customer home because the account is not confirmed

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

    context "as unauthenticated customer" do
      include_context "with unauthenticated customer"

      context "without password reset requested" do
        context "with no password reset token" do
          let(:attributes) { { :password => "newpass", :password_confirmation => "newpass" } }

          before(:each) do
            do_put_update(attributes)
          end
          
          # Variables
          it "should not have current user" do
            subject.current_user.should be_nil
          end

          # Response
          it { should assign_to(:customer) }
          it { should respond_with(:success) }
    
          # Content
          it { should_not set_the_flash }
          it { should render_template(:edit) }
        end

        context "with invalid password reset token" do
          let(:attributes) { { :reset_password_token => "abcdef", :password => "newpass", :password_confirmation => "newpass" } }

          before(:each) do
            do_put_update(attributes)
          end
    
          # Variables
          it "should not have current user" do
            subject.current_user.should be_nil
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
        before(:each) do
          customer.send_reset_password_instructions
          reset_email
          customer.reload
        end

        context "with no password reset token" do
          let(:attributes) { { :password => "newpass", :password_confirmation => "newpass" } }

          before(:each) do
            do_put_update(attributes)
          end
          
          # Variables
          it "should not have current user" do
            subject.current_user.should be_nil
          end

          # Response
          it { should assign_to(:customer) }
          it { should respond_with(:success) }
    
          # Content
          it { should_not set_the_flash }
          it { should render_template(:edit) }
        end
       
        context "with invalid password reset token" do
          let(:attributes) { { :reset_password_token => "abcdef", :password => "newpass", :password_confirmation => "newpass" } }

          before(:each) do
            do_put_update(attributes)
          end

          # Variables
          it "should not have current user" do
            subject.current_user.should be_nil
          end

          # Response
          it { should assign_to(:customer) }
          it { should respond_with(:success) }
    
          # Content
          it { should_not set_the_flash }
          it { should render_template(:edit) }
        end

        context "with valid password reset token" do
          let(:attributes) { { :reset_password_token => "#{customer.reset_password_token}", :password => "newpass", :password_confirmation => "newpass" } }

          before(:each) do
            do_put_update(attributes)
          end
      
          # Variables
          it "should have current customer (logged in)" do
            subject.current_customer.should_not be_nil
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
      include_context "with authenticated customer"
      let(:attributes) { { :password => "newpass", :password_confirmation => "newpass" } }

      before(:each) do
        do_put_update(attributes)
      end
      
      # Variables
      it "should have current customer" do
        subject.current_customer.should_not be_nil
      end

      # Response
      it { should_not assign_to(:customer) }
      it { should respond_with(:redirect) }
      it { should redirect_to(customer_home_path) }

      # Content
      it { should set_the_flash[:alert].to(/already signed in/) }      
    end

    context "as authenticated store" do
      include_context "with authenticated store"
      let(:attributes) { { :password => "newpass", :password_confirmation => "newpass" } }

      before(:each) do
        do_put_update(attributes)
      end

      # Variables
      it "should have current store" do
        subject.current_store.should_not be_nil
      end

      # Response
      it { should_not assign_to(:customer) }
      it { should respond_with(:redirect) }
      it { should redirect_to(customer_scope_conflict_path) }

      # Content
      it { should_not set_the_flash }
    end

    context "as authenticated employee" do
      include_context "with authenticated employee"
      let(:attributes) { { :password => "newpass", :password_confirmation => "newpass" } }

      before(:each) do
        do_put_update(attributes)
      end

      # Variables
      it "should have current employee" do
        subject.current_employee.should_not be_nil
      end

      # Response
      it { should_not assign_to(:customer) }
      it { should respond_with(:redirect) }
      it { should redirect_to(customer_scope_conflict_path) }

      # Content
      it { should_not set_the_flash }
    end
  end
end