require 'spec_helper'

describe Customer::SessionsController do
  include Devise::TestHelpers

  describe "routing", :routing => true do
    let(:customer) { FactoryGirl.create(:customer) }

    it { should route(:get, "/customer/sign_in").to(:action => :new) }
    it { should route(:post, "/customer/sign_in").to(:action => :create) }
    it { should route(:delete, "/customer/sign_out").to(:action => :destroy) }
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
      context "with invalid login", :failing => true do
        before(:each) do
          attributes = {:login => customer.email, :password => "falsepass"}
          post :create, :customer => attributes, :format => 'html'
        end

        # Parameters
#       it { should permit(:email).for(:create) }

        # Response
        it { should_not assign_to(:customer) }
        it { should respond_with(:success) }
  
        # Content
        it { should_not set_the_flash }
      end
      
      context "with valid login (email)" do
        before(:each) do
          attributes = {:login => customer.email, :password => customer.password}
          post :create, :customer => attributes, :format => 'html'
        end

        # Parameters
#       it { should permit(:email).for(:create) }

        # Response
        it { should_not assign_to(:customer) }
        it { should respond_with(:redirect) }
        it { should redirect_to(new_customer_session_path) }
  
        # Content
        it { should set_the_flash[:alert].to(/confirm your account before continuing/) }
      end

      context "with valid login (username)" do
        before(:each) do
          attributes = {:login => customer.username, :password => customer.password}
          post :create, :customer => attributes, :format => 'html'
        end

        # Parameters
#       it { should permit(:email).for(:create) }

        # Response
        it { should_not assign_to(:customer) }
        it { should respond_with(:redirect) }
        it { should redirect_to(new_customer_session_path) }
  
        # Content
        it { should set_the_flash[:alert].to(/confirm your account before continuing/) }
      end
    end

    describe "#destroy", :destroy => true do
      before(:each) do
        delete :destroy, :format => 'html'
      end

      it { should_not assign_to(:customer) }
      it { should respond_with(:redirect) }
      it { should redirect_to(home_path) }

      # Content
      it { should_not set_the_flash }
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
      context "with invalid login", :failing => true do
        before(:each) do
          attributes = {:login => customer.email, :password => "falsepass"}
          post :create, :customer => attributes, :format => 'html'
        end

        # Parameters
#       it { should permit(:email).for(:create) }

        # Response
        it { should_not assign_to(:customer) }
        it { should respond_with(:success) }
  
        # Content
        it { should_not set_the_flash }
      end
      
      context "with valid login (email)" do
        context "no original path" do
          before(:each) do
            attributes = {:login => customer.email, :password => customer.password}
            post :create, :customer => attributes, :format => 'html'
          end
  
          # Parameters
  #       it { should permit(:email).for(:create) }
  
          # Response
          it { should assign_to(:customer) }
          it { should respond_with(:redirect) }
          it { should redirect_to(customer_home_path) }
    
          # Content
          it { should set_the_flash[:notice].to(/Signed in successfully/) }
        end

        context "with original path" do
          before(:each) do
            session[:post_auth_path] = edit_customer_registration_path
            attributes = {:login => customer.email, :password => customer.password}
            post :create, :customer => attributes, :format => 'html'
          end
  
          # Parameters
  #       it { should permit(:email).for(:create) }
  
          # Response
          it { should assign_to(:customer) }
          it { should respond_with(:redirect) }
          it { should redirect_to(edit_customer_registration_path) }
    
          # Content
          it { should set_the_flash[:notice].to(/Signed in successfully/) }
        end
      end

      context "with valid login (username)" do
        context "with no original path" do
          before(:each) do
            attributes = {:login => customer.username, :password => customer.password}
            post :create, :customer => attributes, :format => 'html'
          end
  
          # Parameters
  #       it { should permit(:email).for(:create) }
  
          # Response
          it { should assign_to(:customer) }
          it { should respond_with(:redirect) }
          it { should redirect_to(customer_home_path) }
    
          # Content
          it { should set_the_flash[:notice].to(/Signed in successfully/) }
        end
        context "with original path" do
          before(:each) do
            session[:post_auth_path] = edit_customer_registration_path
            attributes = {:login => customer.username, :password => customer.password}
            post :create, :customer => attributes, :format => 'html'
          end
  
          # Parameters
  #       it { should permit(:email).for(:create) }
  
          # Response
          it { should assign_to(:customer) }
          it { should respond_with(:redirect) }
          it { should redirect_to(edit_customer_registration_path) }
    
          # Content
          it { should set_the_flash[:notice].to(/Signed in successfully/) }
        end
      end
    end

    describe "#destroy", :destroy => true do
      before(:each) do
        delete :destroy, :format => 'html'
      end

      it { should_not assign_to(:customer) }
      it { should respond_with(:redirect) }
      it { should redirect_to(home_path) }

      # Content
      it { should_not set_the_flash }
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
        attributes = {:login => customer.email, :password => "falsepass"}
        post :create, :customer => attributes, :format => 'html'
      end

      # Parameters
#       it { should permit(:email).for(:create) }

      it { should_not assign_to(:customer) }
      it { should respond_with(:redirect) }
      it { should redirect_to(customer_home_path) }

      # Content
      it { should set_the_flash[:alert].to(/already signed in/) }
    end

    describe "#destroy", :destroy => true do
      before(:each) do
        delete :destroy, :format => 'html'
      end

      it { should_not assign_to(:customer) }
      it { should respond_with(:redirect) }
      it { should redirect_to(home_path) }

      # Content
      it { should set_the_flash[:notice].to(/Signed out successfully/) }
    end
  end
end