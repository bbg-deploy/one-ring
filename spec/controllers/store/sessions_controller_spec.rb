require 'spec_helper'

describe Store::SessionsController do
  include Devise::TestHelpers

  describe "routing", :routing => true do
    let(:store) { FactoryGirl.create(:store) }

    it { should route(:get, "/store/sign_in").to(:action => :new) }
    it { should route(:post, "/store/sign_in").to(:action => :create) }
    it { should route(:delete, "/store/sign_out").to(:action => :destroy) }
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
    context "as unauthenticated, unconfirmed store" do
      include_context "as unauthenticated, unconfirmed store"

      describe "valid login" do
        before(:each) do
          attributes = {:login => store.email, :password => store.password}
          post :create, :store => attributes, :format => 'html'
        end

        # Parameters
#       it { should permit(:email).for(:create) }

        # Response
        it { should_not assign_to(:store) }
        it { should respond_with(:redirect) }
        it { should redirect_to(new_store_session_path) }
  
        # Content
        it { should set_the_flash[:alert].to(/confirm your account before continuing/) }
      end
    end

    context "as unauthenticated store" do
      include_context "as unauthenticated store"

      describe "invalid login" do
        before(:each) do
          attributes = {:login => store.email, :password => "wrongpass"}
          post :create, :store => attributes, :format => 'html'
        end

        # Parameters
#       it { should permit(:email).for(:create) }

        # Response
        it { should_not assign_to(:store) }
        it { should respond_with(:success) }
  
        # Content
        it { should_not set_the_flash }
        it { should render_template(:new) }
      end

      describe "valid login (email)" do
        before(:each) do
          attributes = {:login => store.email, :password => store.password}
          post :create, :store => attributes, :format => 'html'
        end

        # Response
        it { should assign_to(:store) }
        it { should respond_with(:redirect) }
        it { should redirect_to(store_home_path) }
  
        # Content
        it { should set_the_flash[:notice].to(/Signed in successfully/) }
      end

      describe "valid login (username)" do
        before(:each) do
          attributes = {:login => store.username, :password => store.password}
          post :create, :store => attributes, :format => 'html'
        end

        # Response
        it { should assign_to(:store) }
        it { should respond_with(:redirect) }
        it { should redirect_to(store_home_path) }
  
        # Content
        it { should set_the_flash[:notice].to(/Signed in successfully/) }
      end
    end

    context "as authenticated store" do
      include_context "as authenticated store"

      before(:each) do
        attributes = {:login => store.username, :password => store.password}
        post :create, :store => attributes, :format => 'html'
      end

      it { should_not assign_to(:store) }
      it { should respond_with(:redirect) }
      it { should redirect_to(store_home_path) }

      # Content
      it { should set_the_flash[:alert].to(/already signed in/) }
    end
  end

  describe "#destroy", :destroy => true do
    context "as unauthenticated store" do
      include_context "as unauthenticated store"

      before(:each) do
        delete :destroy, :format => 'html'
      end

      it { should_not assign_to(:store) }
      it { should respond_with(:redirect) }
      it { should redirect_to(home_path) }

      # Content
      it { should_not set_the_flash }
    end
    
    context "as authenticated store" do
      include_context "as authenticated store"

      before(:each) do
        delete :destroy, :format => 'html'
      end

      it { should_not assign_to(:store) }
      it { should respond_with(:redirect) }
      it { should redirect_to(home_path) }

      # Content
      it { should set_the_flash[:notice].to(/Signed out successfully/) }    end
  end
end