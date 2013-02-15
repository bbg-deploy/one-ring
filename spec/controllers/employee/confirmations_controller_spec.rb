require 'spec_helper'

describe Employee::ConfirmationsController do
  include Devise::TestHelpers

  describe "routing", :routing => true do
    let(:employee) { FactoryGirl.create(:employee) }

    it { should route(:get, "/employee/confirmation/new").to(:action => :new) }
    it { should route(:post, "/employee/confirmation").to(:action => :create) }
    it { should route(:get, "/employee/confirmation").to(:action => :show) }
  end

  describe "#new", :new => true do
    context "as unauthenticated employee" do
      include_context "as unauthenticated employee"
      before(:each) do
        get :new, :format => 'html'
      end

      # Response
      it { should assign_to(:employee) }
      it { should respond_with(:success) }

      # Content
      it { should_not set_the_flash }
      it { should render_template(:new) }
    end

    context "as authenticated employee" do
      include_context "as authenticated employee"
      before(:each) do
        get :new, :format => 'html'
      end

      # Response
      it { should_not assign_to(:employee) }
      it { should respond_with(:redirect) }
      it { should redirect_to(employee_home_path) }

      # Content
      it { should set_the_flash[:alert].to(/already signed in/) }
    end
  end

  describe "#create", :create => true do
    context "as unauthenticated, unconfirmed employee" do
      include_context "as unauthenticated, unconfirmed employee"

      describe "with invalid email" do
        before(:each) do
          attributes = {:email => "fake@email.com"}
          post :create, :employee => attributes, :format => 'html'
        end

        # Parameters
#       it { should permit(:email).for(:create) }

        # Response
        it { should assign_to(:employee) }
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
          attributes = {:email => employee.email}
          post :create, :employee => attributes, :format => 'html'
        end

        # Parameters
#       it { should permit(:email).for(:create) }

        # Response
        it { should assign_to(:employee) }
        it { should respond_with(:redirect) }
        it { should redirect_to(home_path) }

        # Content
        it { should set_the_flash[:notice].to(/email with instructions about how to confirm/) }

        # Behavior
        it "should send confirmation email" do
          last_email.should_not be_nil
          last_email.to.should eq([employee.email])
          last_email.body.should match(/#{employee.confirmation_token}/)
        end
      end
    end

    context "as unauthenticated, confirmed employee" do
      include_context "as unauthenticated employee"

      describe "with valid email" do
        before(:each) do
          reset_email
          attributes = {:email => employee.email}
          post :create, :employee => attributes, :format => 'html'
        end

        # Parameters
#       it { should permit(:email).for(:create) }

        # Response
        it { should assign_to(:employee) }
        it { should respond_with(:success) }

        # Content
        it { should render_template(:new) }

        # Behavior
        it "should not send email" do
          last_email.should be_nil
        end
      end
    end
    
    context "as authenticated employee" do
      include_context "as authenticated employee"

      describe "with valid email" do
        before(:each) do
          attributes = {:email => employee.email}
          post :create, :employee => attributes, :format => 'html'
        end
  
        # Parameters
  #       it { should permit(:email).for(:create) }
  
        # Response
        it { should_not assign_to(:employee) }
        it { should respond_with(:redirect) }
        it { should redirect_to(employee_home_path) }
  
        # Content
        it { should set_the_flash[:alert].to(/already signed in/) }
      end
    end
  end

  describe "#show", :show => true do
    context "as unauthenticated, unconfirmed employee" do
      include_context "as unauthenticated, unconfirmed employee"
      
      describe "with invalid token" do
        before(:each) do
          @request.env['QUERY_STRING'] = "confirmation_token="
          get :show, :confirmation_token => "1234234234", :format => 'html'
        end

        # Response
        it { should assign_to(:employee) }
        it { should respond_with(:success) }

        # Content
        it { should_not set_the_flash }
        it { should render_template(:new) }
      end

      describe "with valid token" do
        before(:each) do
          @request.env['QUERY_STRING'] = "confirmation_token="
          get :show, :confirmation_token => "#{employee.confirmation_token}", :format => 'html'
        end        

        # Response
        it { should assign_to(:employee) }
        it { should redirect_to(employee_home_path) }
  
        # Content
        it { should set_the_flash[:notice].to(/successfully confirmed/) }
      end
    end
    
    context "as authenticated employee" do
      include_context "as authenticated employee"

      describe "with valid token" do
        before(:each) do
          @request.env['QUERY_STRING'] = "confirmation_token="
          get :show, :confirmation_token => "#{employee.confirmation_token}", :format => 'html'
        end        

        # Response
        it { should_not assign_to(:employee) }
        it { should redirect_to(employee_home_path) }
  
        # Content
        it { should set_the_flash[:alert].to(/already signed in/) }
      end
    end
  end
end