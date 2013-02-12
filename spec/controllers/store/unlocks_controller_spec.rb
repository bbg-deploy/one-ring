require 'spec_helper'

describe Store::UnlocksController do
  include Devise::TestHelpers

  describe "routing", :routing => true do
    let(:store) { FactoryGirl.create(:store) }

    it { should route(:get, "/store/unlock/new").to(:action => :new) }
    it { should route(:post, "/store/unlock").to(:action => :create) }
    it { should route(:get, "/store/unlock").to(:action => :show) }
  end

  describe "#new", :new => true do
    context "as unauthenticated store" do
      include_context "as unauthenticated store"

      before(:each) do
        get :new, :format => 'html'
      end

      # Response
      it { should assign_to(:store) }
      it { should respond_with(:success) }

      # Content
      it { should_not set_the_flash }
      it { should render_template(:new) }
    end

    context "as authenticated store" do
      include_context "as authenticated store"
 
      before(:each) do
        get :new, :format => 'html'
      end

       # Response
      it { should_not assign_to(:store) }
      it { should respond_with(:redirect) }
      it { should redirect_to(store_home_path) }

      # Content
      it { should set_the_flash[:alert].to(/already signed in/) }
    end
  end

  describe "#create", :create => true do
    context "as unauthenticated, unlocked store" do
      include_context "as unauthenticated store"

      before(:each) do
        attributes = {:email => store.email}
        post :create, :store => attributes, :format => 'html'
      end

      # Parameters
#       it { should permit(:email).for(:create) }

      # Response
      it { should assign_to(:store) }
      it { should respond_with(:success) }

      # Content
      it { should_not set_the_flash }
      it { should render_template(:new) }

      # Behavior
      it "should not send confirmation email" do
        last_email.should be_nil
      end
    end

    context "as unauthenticated, locked store" do
      include_context "as unauthenticated, locked store"

      describe "invalid email" do
        before(:each) do
          attributes = {:email => "invalid@email.com"}
          post :create, :store => attributes, :format => 'html'
        end
  
        # Parameters
  #       it { should permit(:email).for(:create) }
  
        # Response
        it { should assign_to(:store) }
        it { should respond_with(:success) }
  
        # Content
        it { should_not set_the_flash }
        it { should render_template(:new) }
      end

      describe "valid email" do
        before(:each) do
          attributes = {:email => store.email}
          post :create, :store => attributes, :format => 'html'
        end
  
        # Parameters
  #       it { should permit(:email).for(:create) }
  
        # Response
        it { should assign_to(:store) }
        it { should respond_with(:redirect) }
        it { should redirect_to(new_store_session_path) }
  
        # Content
        it { should set_the_flash[:notice].to(/email with instructions about how to unlock/) }
      end
    end

    context "as authenticated store" do
      include_context "as authenticated store"
 
      before(:each) do
        attributes = {:email => store.email}
        post :create, :store => attributes, :format => 'html'
      end

       # Response
      it { should_not assign_to(:store) }
      it { should respond_with(:redirect) }
      it { should redirect_to(store_home_path) }

      # Content
      it { should set_the_flash[:alert].to(/already signed in/) }
    end
  end

  describe "#show", :show => true do
    context "as unauthenticated, locked store" do
      include_context "as unauthenticated, locked store"
      
      describe "without token" do
        before(:each) do
          get :show, :format => 'html'
        end

        # Response
        it { should assign_to(:store) }
        it { should respond_with(:success) }

        # Content
        it { should_not set_the_flash }
        it { should render_template(:new) }
      end

      describe "with invalid token" do
        before(:each) do
          @request.env['QUERY_STRING'] = "unlock_token="
          get :show, :unlock_token => "1234234234", :format => 'html'
        end

        # Response
        it { should assign_to(:store) }
        it { should respond_with(:success) }

        # Content
        it { should_not set_the_flash }
        it { should render_template(:new) }
      end

      describe "with valid token" do
        before(:each) do
          @request.env['QUERY_STRING'] = "unlock_token="
          get :show, :unlock_token => "#{store.unlock_token}", :format => 'html'
        end        

        # Response
        it { should assign_to(:store) }
        it { should redirect_to(new_store_session_path) }
  
        # Content
        it { should set_the_flash[:notice].to(/unlocked successfully. Please sign in/) }
      end
    end

    context "as authenticated store" do
      include_context "as authenticated store"
 
      before(:each) do
        @request.env['QUERY_STRING'] = "unlock_token="
        get :show, :unlock_token => "abcdef", :format => 'html'
      end        

       # Response
      it { should_not assign_to(:store) }
      it { should respond_with(:redirect) }
      it { should redirect_to(store_home_path) }

      # Content
      it { should set_the_flash[:alert].to(/already signed in/) }
    end
  end
end