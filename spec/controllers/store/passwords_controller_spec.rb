require 'spec_helper'

describe Store::PasswordsController do
  describe "routing", :routing => true do
    it { should route(:get, "/store/password/new").to(:action => :new) }
    it { should route(:post, "/store/password").to(:action => :create) }
    it { should route(:get, "/store/password/edit").to(:action => :edit) }
    it { should route(:put, "/store/password").to(:action => :update) }
  end

  describe "#new", :new => true do
    context "as unauthenticated store" do
      include_context "with unauthenticated store"
      before(:each) do
        @request.env["devise.mapping"] = Devise.mappings[:store]
        get :new, :format => 'html'
      end

      it "should not have store" do
        subject.try(:current_store).should be_nil
      end
      
      # Variables
      it "should not have current user" do
        subject.current_user.should be_nil
        subject.current_store.should be_nil
      end

      # Response
      it { should assign_to(:store) }
      it { should respond_with(:success) }

      # Content
      it { should_not set_the_flash }
      it { should render_template(:new) }
    end

    context "as authenticated store" do
      include_context "with authenticated store"
      before(:each) do
        @request.env["devise.mapping"] = Devise.mappings[:store]
        get :new, :format => 'html'
      end
      
      # Variables
      it "should have current store" do
        subject.current_user.should_not be_nil
        subject.current_store.should_not be_nil
      end

      # Response
      it { should_not assign_to(:store) }
      it { should respond_with(:redirect) }
      it { should redirect_to(store_home_path) }

      # Content
      it { should set_the_flash[:alert].to(/already signed in/) }      
    end

    context "as authenticated customer" do
      include_context "with authenticated customer"
      before(:each) do
        @request.env["devise.mapping"] = Devise.mappings[:store]
        get :new, :format => 'html'
      end

      # Variables
      it "should have current customer" do
        subject.current_user.should_not be_nil
        subject.current_store.should be_nil
        subject.current_customer.should_not be_nil
      end

      # Response
      it { should_not assign_to(:store) }
      it { should respond_with(:redirect) }
      it { should redirect_to(store_scope_conflict_path) }

      # Content
      it { should_not set_the_flash }
    end

    context "as authenticated employee" do
      include_context "with authenticated employee"
      before(:each) do
        @request.env["devise.mapping"] = Devise.mappings[:store]
        get :new, :format => 'html'
      end

      # Variables
      it "should have current employee" do
        subject.current_user.should_not be_nil
        subject.current_store.should be_nil
        subject.current_employee.should_not be_nil
      end

      # Response
      it { should_not assign_to(:store) }
      it { should respond_with(:redirect) }
      it { should redirect_to(store_scope_conflict_path) }

      # Content
      it { should_not set_the_flash }
    end
  end

  describe "#create", :create => true do
    context "as unauthenticated store" do
      include_context "with unauthenticated store"

      describe "with mismatched email" do
        before(:each) do
          @request.env["devise.mapping"] = Devise.mappings[:store]
          attributes = {:email => "fake@fakemail.com"}
          post :create, :store => attributes, :format => 'html'
        end        

        # Parameters
#       it { should permit(:email).for(:create) }

        # Variables
        it "should not have current user" do
          subject.current_user.should be_nil
          subject.current_store.should be_nil
        end

        # Response
        it { should assign_to(:store) }
        it { should respond_with(:success) }

        # Content
        it { should_not set_the_flash }
        it { should render_template(:new) }

        # Behavior
        it "did not send confirmation email" do
          last_email.should be_nil
        end
      end
      
      describe "with matching email" do
        before(:each) do
          @request.env["devise.mapping"] = Devise.mappings[:store]
          attributes = {:email => store.email}
          post :create, :store => attributes, :format => 'html'
        end
        
        # Parameters
#       it { should permit(:email).for(:create) }

        # Variables
        it "should not have current user" do
          subject.current_user.should be_nil
          subject.current_store.should be_nil
        end

        # Response
        it { should assign_to(:store) }
        it { should respond_with(:redirect) }
        it { should redirect_to(new_store_session_path) }

        # Content
        it { should set_the_flash[:notice].to(/receive an email with instructions about how to reset your password/) }

        # Behavior
        it "sent confirmation email" do
          last_email.should_not be_nil
          last_email.to.should eq([store.email])
          last_email.body.should match(/#{store.reset_password_token}/)
        end
      end
    end

    context "as authenticated store" do
      include_context "with authenticated store"
      before(:each) do
        @request.env["devise.mapping"] = Devise.mappings[:store]
        attributes = {:email => store.email}
        post :create, :store => attributes, :format => 'html'
      end
      
      # Variables
      it "should have current store" do
        subject.current_user.should_not be_nil
        subject.current_store.should_not be_nil
      end

      # Response
      it { should_not assign_to(:store) }
      it { should respond_with(:redirect) }
      it { should redirect_to(store_home_path) }

      # Content
      it { should set_the_flash[:alert].to(/already signed in/) }      
    end

    context "as authenticated customer" do
      include_context "with authenticated customer"
      before(:each) do
        @request.env["devise.mapping"] = Devise.mappings[:store]
        store = FactoryGirl.create(:store)
        attributes = {:email => store.email}
        post :create, :store => attributes, :format => 'html'
      end

      # Variables
      it "should have current customer" do
        subject.current_user.should_not be_nil
        subject.current_store.should be_nil
        subject.current_customer.should_not be_nil
      end

      # Response
      it { should_not assign_to(:store) }
      it { should respond_with(:redirect) }
      it { should redirect_to(store_scope_conflict_path) }

      # Content
      it { should_not set_the_flash }
    end

    context "as authenticated employee" do
      include_context "with authenticated employee"
      before(:each) do
        @request.env["devise.mapping"] = Devise.mappings[:store]
        store = FactoryGirl.create(:store)
        attributes = {:email => store.email}
        post :create, :store => attributes, :format => 'html'
      end

      # Variables
      it "should have current employee" do
        subject.current_user.should_not be_nil
        subject.current_store.should be_nil
        subject.current_employee.should_not be_nil
      end

      # Response
      it { should_not assign_to(:store) }
      it { should respond_with(:redirect) }
      it { should redirect_to(store_scope_conflict_path) }

      # Content
      it { should_not set_the_flash }
    end
  end

  describe "#edit", :edit => true do
    context "as unauthenticated store" do
      include_context "with unauthenticated store"

      context "without password reset requested" do
        describe "no password reset token" do
          before(:each) do
            @request.env["devise.mapping"] = Devise.mappings[:store]
            get :edit, :format => 'html'
          end
          
          # Variables
          it "should not have current user" do
            subject.current_user.should be_nil
            subject.current_store.should be_nil
          end
    
          # Response
          it { should_not assign_to(:store) }
          it { should respond_with(:redirect) }
          it { should redirect_to(new_store_session_path) }
    
          # Content
          it { should set_the_flash[:error].to(/can't access this page without coming from a password reset email/) }
        end

        describe "with invalid password reset token" do
          before(:each) do
            @request.env["devise.mapping"] = Devise.mappings[:store]
            @request.env['QUERY_STRING'] = "reset_password_token="
            get :edit, :reset_password_token => "abcdef", :format => 'html'
          end
    
          # Variables
          it "should not have current user" do
            subject.current_user.should be_nil
            subject.current_store.should be_nil
          end

          # Response
          it { should assign_to(:store) }
          it { should respond_with(:redirect) }
          it { should redirect_to(new_store_session_path) }
    
          # Content
          it { should set_the_flash[:alert].to(/reset token is invalid or expired/) }
        end
      end      

      context "with password reset requested" do
        describe "no password reset token" do
          before(:each) do
            store.send_reset_password_instructions
            reset_email
            store.reload
            @request.env["devise.mapping"] = Devise.mappings[:store]
            get :edit, :format => 'html'
          end
          
          # Variables
          it "should not have current user" do
            subject.current_user.should be_nil
            subject.current_store.should be_nil
          end

          # Response
          it { should_not assign_to(:store) }
          it { should respond_with(:redirect) }
          it { should redirect_to(new_store_session_path) }
    
          # Content
          it { should set_the_flash[:error].to(/can't access this page without coming from a password reset email/) }
        end

        describe "with invalid password reset token" do
          before(:each) do
            store.send_reset_password_instructions
            reset_email
            store.reload
            @request.env["devise.mapping"] = Devise.mappings[:store]
            @request.env['QUERY_STRING'] = "reset_password_token="
            get :edit, :reset_password_token => "abcdef", :format => 'html'
          end
    
          # Variables
          it "should not have current user" do
            subject.current_user.should be_nil
            subject.current_store.should be_nil
          end

          # Response
          it { should assign_to(:store) }
          it { should respond_with(:redirect) }
          it { should redirect_to(new_store_session_path) }
    
          # Content
          it { should set_the_flash[:alert].to(/reset token is invalid or expired/) }
        end

        describe "valid password reset token" do
          before(:each) do
            store.send_reset_password_instructions
            reset_email
            store.reload
            @request.env["devise.mapping"] = Devise.mappings[:store]
            @request.env['QUERY_STRING'] = "reset_password_token="
            get :edit, :reset_password_token => "#{store.reset_password_token}", :format => 'html'
          end
    
          # Variables
          it "should not have current user" do
            subject.current_user.should be_nil
            subject.current_store.should be_nil
          end

          # Response
          it { should assign_to(:store) }
          it { should respond_with(:success) }
    
          # Content
          it { should_not set_the_flash }
          it { should render_template(:edit) }
        end
      end      
    end

    context "as authenticated store" do
      include_context "with authenticated store"

      before(:each) do
        @request.env["devise.mapping"] = Devise.mappings[:store]
        get :edit, :format => 'html'
      end
      
      # Variables
      it "should have current store" do
        subject.current_user.should_not be_nil
        subject.current_store.should_not be_nil
      end

      # Response
      it { should_not assign_to(:store) }
      it { should respond_with(:redirect) }
      it { should redirect_to(store_home_path) }

      # Content
      it { should set_the_flash[:alert].to(/already signed in/) }      
    end

    context "as authenticated customer" do
      include_context "with authenticated customer"
      before(:each) do
        @request.env["devise.mapping"] = Devise.mappings[:store]
        get :edit, :format => 'html'
      end

      # Variables
      it "should have current customer" do
        subject.current_user.should_not be_nil
        subject.current_store.should be_nil
        subject.current_customer.should_not be_nil
      end

      # Response
      it { should_not assign_to(:store) }
      it { should respond_with(:redirect) }
      it { should redirect_to(new_store_session_path) }

      # Content
      it { should set_the_flash[:error].to(/can't access this page without coming from a password reset email/) }
    end

    context "as authenticated employee" do
      include_context "with authenticated employee"
      before(:each) do
        @request.env["devise.mapping"] = Devise.mappings[:store]
        get :edit, :format => 'html'
      end

      # Variables
      it "should have current store" do
        subject.current_user.should_not be_nil
        subject.current_store.should be_nil
        subject.current_employee.should_not be_nil
      end

      # Response
      it { should_not assign_to(:store) }
      it { should respond_with(:redirect) }
      it { should redirect_to(new_store_session_path) }

      # Content
      it { should set_the_flash[:error].to(/can't access this page without coming from a password reset email/) }
    end
  end

  describe "#update", :update => true do
    context "with unapproved store" do
      include_context "with unapproved store"

      context "without password reset requested" do
        describe "with no password reset token" do
          before(:each) do
            @request.env["devise.mapping"] = Devise.mappings[:store]
            attributes = {:password => "newpass", :password_confirmation => "newpass"}
            put :update, :store => attributes, :format => 'html'
          end
          
          # Variables
          it "should not have current user" do
            subject.current_user.should be_nil
            subject.current_store.should be_nil
          end
    
          # Response
          it { should assign_to(:store) }
          it { should respond_with(:success) }
    
          # Content
          it { should_not set_the_flash }
          it { should render_template(:edit) }
        end

        describe "with invalid password reset token" do
          before(:each) do
            @request.env["devise.mapping"] = Devise.mappings[:store]
            attributes = {:reset_password_token => "#abcdef", :password => "newpass", :password_confirmation => "newpass"}
            put :update, :store => attributes, :format => 'html'
          end
    
          # Variables
          it "should not have current user" do
            subject.current_user.should be_nil
            subject.current_store.should be_nil
          end

          # Response
          it { should assign_to(:store) }
          it { should respond_with(:success) }
    
          # Content
          it { should_not set_the_flash }
          it { should render_template(:edit) }
        end
      end

      context "with password reset requested" do
        describe "with no password reset token" do
          before(:each) do
            store.send_reset_password_instructions
            reset_email
            store.reload
            @request.env["devise.mapping"] = Devise.mappings[:store]
            attributes = {:password => "newpass", :password_confirmation => "newpass"}
            put :update, :store => attributes, :format => 'html'
          end
          
          # Variables
          it "should not have current user" do
            subject.current_user.should be_nil
            subject.current_store.should be_nil
          end

          # Response
          it { should assign_to(:store) }
          it { should respond_with(:success) }
    
          # Content
          it { should_not set_the_flash }
          it { should render_template(:edit) }
        end
       
        describe "with invalid password reset token" do
          before(:each) do
            store.send_reset_password_instructions
            reset_email
            store.reload
            @request.env["devise.mapping"] = Devise.mappings[:store]
            attributes = {:reset_password_token => "#abcdef", :password => "newpass", :password_confirmation => "newpass"}
            put :update, :store => attributes, :format => 'html'
          end
    
          # Variables
          it "should not have current user" do
            subject.current_user.should be_nil
            subject.current_store.should be_nil
          end

          # Response
          it { should assign_to(:store) }
          it { should respond_with(:success) }
    
          # Content
          it { should_not set_the_flash }
          it { should render_template(:edit) }
        end

        describe "with valid password reset token" do
          before(:each) do
            store.send_reset_password_instructions
            reset_email
            store.reload
            @request.env["devise.mapping"] = Devise.mappings[:store]
            attributes = {:reset_password_token => "#{store.reset_password_token}", :password => "newpass", :password_confirmation => "newpass"}
            put :update, :store => attributes, :format => 'html'
          end
      
          # Variables
          it "should not have current user" do
            subject.current_user.should be_nil
            subject.current_store.should be_nil
          end

          # Response
          it { should assign_to(:store) }
          it { should respond_with(:redirect) }
          it { should redirect_to(new_store_session_path) } # Should go to sign-in page instead of store home because the account is not confirmed

          # Content
          it { should set_the_flash[:notice].to(/password was changed successfully/) }
          it { should set_the_flash[:alert].to(/account has not been approved/) }
            
          # Behavior
          it "should change password" do
            original_pass = store.encrypted_password
            store.reload
            store.encrypted_password.should_not eq(original_pass)
          end    
        end        
      end
    end

    context "as unauthenticated store" do
      include_context "with unauthenticated store"

      context "without password reset requested" do
        describe "with no password reset token" do
          before(:each) do
            @request.env["devise.mapping"] = Devise.mappings[:store]
            attributes = {:password => "newpass", :password_confirmation => "newpass"}
            put :update, :store => attributes, :format => 'html'
          end
          
          # Variables
          it "should not have current user" do
            subject.current_user.should be_nil
            subject.current_store.should be_nil
          end

          # Response
          it { should assign_to(:store) }
          it { should respond_with(:success) }
    
          # Content
          it { should_not set_the_flash }
          it { should render_template(:edit) }
        end

        describe "with invalid password reset token" do
          before(:each) do
            @request.env["devise.mapping"] = Devise.mappings[:store]
            attributes = {:reset_password_token => "#abcdef", :password => "newpass", :password_confirmation => "newpass"}
            put :update, :store => attributes, :format => 'html'
          end
    
          # Variables
          it "should not have current user" do
            subject.current_user.should be_nil
            subject.current_store.should be_nil
          end

          # Response
          it { should assign_to(:store) }
          it { should respond_with(:success) }
    
          # Content
          it { should_not set_the_flash }
          it { should render_template(:edit) }
        end
      end

      context "with password reset requested" do
        describe "with no password reset token" do
          before(:each) do
            store.send_reset_password_instructions
            reset_email
            store.reload
            @request.env["devise.mapping"] = Devise.mappings[:store]
            attributes = {:password => "newpass", :password_confirmation => "newpass"}
            put :update, :store => attributes, :format => 'html'
          end
          
          # Response
          it { should assign_to(:store) }
          it { should respond_with(:success) }
    
          # Content
          it { should_not set_the_flash }
          it { should render_template(:edit) }
        end
       
        describe "with invalid password reset token" do
          before(:each) do
            store.send_reset_password_instructions
            reset_email
            store.reload
            @request.env["devise.mapping"] = Devise.mappings[:store]
            attributes = {:reset_password_token => "#abcdef", :password => "newpass", :password_confirmation => "newpass"}
            put :update, :store => attributes, :format => 'html'
          end
    
          # Response
          it { should assign_to(:store) }
          it { should respond_with(:success) }
    
          # Content
          it { should_not set_the_flash }
          it { should render_template(:edit) }
        end

        describe "with valid password reset token" do
          before(:each) do
            store.send_reset_password_instructions
            reset_email
            store.reload
            @request.env["devise.mapping"] = Devise.mappings[:store]
            attributes = {:reset_password_token => "#{store.reset_password_token}", :password => "newpass", :password_confirmation => "newpass"}
            put :update, :store => attributes, :format => 'html'
          end
      
          # Response
          it { should assign_to(:store) }
          it { should respond_with(:redirect) }
          it { should redirect_to(store_home_path) }
      
          # Content
          it { should set_the_flash[:notice].to(/password was changed successfully. You are now signed in/) }
            
          # Behavior
          it "should change password" do
            original_pass = store.encrypted_password
            store.reload
            store.encrypted_password.should_not eq(original_pass)
          end    
        end        
      end
    end

    context "as authenticated store" do
      include_context "with authenticated store"
      before(:each) do
        store.send_reset_password_instructions
        reset_email
        store.reload
        @request.env["devise.mapping"] = Devise.mappings[:store]
        attributes = {:password => "newpass", :password_confirmation => "newpass"}
        put :update, :store => attributes, :format => 'html'
      end
      
      # Variables
      it "should have current store" do
        subject.current_user.should_not be_nil
        subject.current_store.should_not be_nil
      end

      # Response
      it { should_not assign_to(:store) }
      it { should respond_with(:redirect) }
      it { should redirect_to(store_home_path) }

      # Content
      it { should set_the_flash[:alert].to(/already signed in/) }      
    end

    context "as authenticated customer" do
      include_context "with authenticated customer"
      before(:each) do
        @request.env["devise.mapping"] = Devise.mappings[:store]
        attributes = {:password => "newpass", :password_confirmation => "newpass"}
        put :update, :store => attributes, :format => 'html'
      end

      # Variables
      it "should have current customer" do
        subject.current_user.should_not be_nil
        subject.current_store.should be_nil
        subject.current_customer.should_not be_nil
      end

      # Response
      it { should_not assign_to(:store) }
      it { should respond_with(:redirect) }
      it { should redirect_to(store_scope_conflict_path) }

      # Content
      it { should_not set_the_flash }
    end

    context "as authenticated employee" do
      include_context "with authenticated employee"
      before(:each) do
        @request.env["devise.mapping"] = Devise.mappings[:store]
        attributes = {:password => "newpass", :password_confirmation => "newpass"}
        put :update, :store => attributes, :format => 'html'
      end

      # Variables
      it "should have current employee" do
        subject.current_user.should_not be_nil
        subject.current_store.should be_nil
        subject.current_employee.should_not be_nil
      end

      # Response
      it { should_not assign_to(:store) }
      it { should respond_with(:redirect) }
      it { should redirect_to(store_scope_conflict_path) }

      # Content
      it { should_not set_the_flash }
    end
  end
end