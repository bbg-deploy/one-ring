require 'spec_helper'

describe ClientsController do
  include Devise::TestHelpers

  describe "routing", :routing => true do
    it { should route(:get, "/clients").to(:action => :index) }
    it { should route(:get, "/clients/new").to(:action => :new) }
    it { should route(:post, "/clients").to(:action => :create) }
    it { should route(:get, "/clients/1").to(:action => :show, :id => 1) }
    it { should route(:get, "/clients/1/edit").to(:action => :edit, :id => 1) }
    it { should route(:put, "/clients/1").to(:action => :update, :id => 1) }
    it { should route(:delete, "/clients/1").to(:action => :destroy, :id => 1) }
  end

  describe "#new", :new => true do
    context "as unauthenticated employee" do
      include_context "as unauthenticated employee"
      before(:each) do
        get :new, :format => 'html'
      end

      # Response
      it { should_not assign_to(:client) }
      it { should respond_with(:redirect) }
      it { should redirect_to(new_employee_session_path) }

      # Content
      it { should set_the_flash[:alert].to(/sign in or sign up/) }
    end

    context "as authenticated employee" do
      include_context "as authenticated employee"
      before(:each) do
        get :new, :format => 'html'
      end

      # Response
      it { should assign_to(:client) }
      it { should respond_with(:success) }

      # Content
      it { should_not set_the_flash }
      it { should render_template(:new) }
    end
  end

  describe "#create", :create => true do
    context "as unauthenticated employee" do
      include_context "as unauthenticated employee"

      let(:attributes) { FactoryGirl.build(:client_attributes_hash) }
      before(:each) do
        post :create, :client => attributes, :format => 'html'
      end

      # Response
      it { should_not assign_to(:client) }
      it { should respond_with(:redirect) }
      it { should redirect_to(new_employee_session_path) }

      # Content
      it { should set_the_flash[:alert].to(/need to sign in or sign up/) }

      # Behavior
      it "should not create new Client" do
        expect {
          attributes = FactoryGirl.build(:client_attributes_hash)
          post :create, :client => attributes, :format => 'html'
        }.to_not change(Client, :count)
      end
    end

    context "as authenticated employee" do
      include_context "as authenticated employee"

      let(:attributes) { FactoryGirl.build(:client_attributes_hash) }
      before(:each) do
        post :create, :client => attributes, :format => 'html'
      end

      # Response
      it { should assign_to(:client) }
      it { should respond_with(:redirect) }
      it { should redirect_to(client_path(Client.last)) }

      # Content
      it { should set_the_flash[:notice].to(/Successfully created client/) }

      # Behavior
      it "should create new Client" do
        expect {
          attributes = FactoryGirl.build(:client_attributes_hash)
          post :create, :client => attributes, :format => 'html'
        }.to change(Client, :count).by(1)
      end
    end
  end

  describe "#show", :show => true do
    context "as unauthenticated employee" do
      include_context "as unauthenticated employee"
      
      let(:client) { FactoryGirl.create(:client) }
      before(:each) do
        get :show, :id => client.id, :format => 'html'
      end

      # Response
      it { should_not assign_to(:client) }
      it { should respond_with(:redirect) }
      it { should redirect_to(new_employee_session_path) }

      # Content
      it { should set_the_flash[:alert].to(/need to sign in or sign up/) }
    end
    
    context "as authenticated employee" do
      include_context "as authenticated employee"

      let(:client) { FactoryGirl.create(:client) }
      before(:each) do
        get :show, :id => client.id, :format => 'html'
      end

      # Response
      it { should assign_to(:client) }
      it { should respond_with(:success) }

      # Content
      it { should_not set_the_flash }
      it { should render_template(:show) }
    end
  end

  describe "#edit", :edit => true do
    context "as unauthenticated employee" do
      include_context "as unauthenticated employee"
      
      let(:client) { FactoryGirl.create(:client) }
      before(:each) do
        get :edit, :id => client.id, :format => 'html'
      end

      # Response
      it { should_not assign_to(:client) }
      it { should respond_with(:redirect) }
      it { should redirect_to(new_employee_session_path) }

      # Content
      it { should set_the_flash[:alert].to(/need to sign in or sign up/) }
    end
    
    context "as authenticated employee" do
      include_context "as authenticated employee"

      let(:client) { FactoryGirl.create(:client) }
      before(:each) do
        get :edit, :id => client.id, :format => 'html'
      end

      # Response
      it { should assign_to(:client) }
      it { should respond_with(:success) }

      # Content
      it { should_not set_the_flash }
      it { should render_template(:edit) }
    end
  end

  describe "#update", :update => true do
    context "as unauthenticated employee" do
      include_context "as unauthenticated employee"
      
      let(:client) { FactoryGirl.create(:client) }
      let(:attributes) { { :name => "NewApplication" } }
      before(:each) do
        put :update, :id => client.id, :client => attributes, :format => 'html'
      end

      # Response
      it { should_not assign_to(:client) }
      it { should respond_with(:redirect) }
      it { should redirect_to(new_employee_session_path) }

      # Content
      it { should set_the_flash[:alert].to(/need to sign in or sign up/) }

      # Behavior
      it "should not update Client" do
        client.name.should_not eq("NewApplication")
        client.reload
        client.name.should_not eq("NewApplication")
      end
    end
    
    context "as authenticated employee" do
      include_context "as authenticated employee"

      let(:client) { FactoryGirl.create(:client) }
      let(:attributes) { { :name => "NewApplication" } }
      before(:each) do
        put :update, :id => client.id, :client => attributes, :format => 'html'
      end

      # Response
      it { should assign_to(:client) }
      it { should respond_with(:redirect) }
      it { should redirect_to(client_path(client.id)) }

      # Content
      it { should set_the_flash[:notice].to(/Successfully updated/) }

      # Behavior
      it "should change name" do
        client.name.should_not eq("NewApplication")
        client.reload
        client.name.should eq("NewApplication")
      end
    end
  end

  describe "#destroy", :destroy => true do
    context "as unauthenticated employee" do
      include_context "as unauthenticated employee"
      
      let(:client) { FactoryGirl.create(:client) }
      before(:each) do
        delete :destroy, :id => client.id, :format => 'html'
      end

      # Response
      it { should_not assign_to(:client) }
      it { should respond_with(:redirect) }
      it { should redirect_to(new_employee_session_path) }

      # Content
      it { should set_the_flash[:alert].to(/need to sign in or sign up/) }

      # Behavior
      it "should persist Client" do
        expect { client.reload }.to_not raise_error
      end

      it "should not delete Client" do
        client = FactoryGirl.create(:client)
        expect {
          delete :destroy, :id => client.id, :format => 'html'
        }.to_not change(Client, :count)
      end
    end
    
    context "as authenticated employee" do
      include_context "as authenticated employee"

      let(:client) { FactoryGirl.create(:client) }
      before(:each) do
        delete :destroy, :id => client.id, :format => 'html'
      end

      # Response
      it { should assign_to(:client) }
      it { should respond_with(:redirect) }
      it { should redirect_to(clients_path) }

      # Content
      it { should set_the_flash[:notice].to(/Successfully deleted/) }

      # Behavior
      it "should not persist Client" do
        expect { client.reload }.to raise_error
      end

      it "should delete Client" do
        client = FactoryGirl.create(:client)
        expect {
          delete :destroy, :id => client.id, :format => 'html'
        }.to change(Client, :count).by(-1)
      end
    end
  end
end