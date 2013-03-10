require 'spec_helper'

describe Employee::StoresController do
  # Controller Shared Methods
  #----------------------------------------------------------------------------
  def do_get_new
    get :new, :format => 'html'
  end

  def do_post_create(attributes)
    post :create, :store => attributes, :format => 'html'
  end

  def do_get_edit(id)
    get :edit, :id => id,:format => 'html'
  end
  
  def do_put_update(id, attributes)
    put :update, :id => id, :store => attributes, :format => 'html'
  end

  def do_get_show(id)
    get :show, :id => id, :format => 'html'
  end

  def do_delete_destroy(id)
    delete :destroy, :id => id, :format => 'html'
  end

  # Routing
  #----------------------------------------------------------------------------
  describe "routing", :routing => true do
    it { should route(:get, "/employee/stores").to(:action => :index) }
    it { should route(:get, "/employee/stores/new").to(:action => :new) }
    it { should route(:post, "/employee/stores").to(:action => :create) }
    it { should route(:get, "/employee/stores/1").to(:action => :show, :id => 1) }
    it { should route(:get, "/employee/stores/1/edit").to(:action => :edit, :id => 1) }
    it { should route(:put, "/employee/stores/1").to(:action => :update, :id => 1) }
    it { should route(:delete, "/employee/stores/1").to(:action => :destroy, :id => 1) }
  end

  # Methods
  #----------------------------------------------------------------------------
  describe "#new", :new => true do
    context "as unauthenticated employee" do
      include_context "with unauthenticated employee"
      before(:each) do
        do_get_new
      end

      # Variables
      it "does not have current user" do
        subject.current_user.should be_nil
      end

      # Response
      it { should_not assign_to(:store) }
      it { should respond_with(:redirect) }
      it { should redirect_to(new_employee_session_path) }

      # Content
      it { should set_the_flash[:alert].to(/need to sign in or sign up/) }
    end

    context "as authenticated employee" do
      include_context "with authenticated employee"
      before(:each) do
        do_get_new
      end

      # Variables
      it "has current employee" do
        subject.current_employee.should_not be_nil
      end

      # Response
      it { should assign_to(:store) }
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
      it "has current customer" do
        subject.current_customer.should_not be_nil
      end

      # Response
      it { should_not assign_to(:store) }
      it { should respond_with(:redirect) }
      it { should redirect_to(new_employee_session_path) }

      # Content
      it { should set_the_flash[:alert].to(/need to sign in or sign up/) }
    end

    context "as authenticated store" do
      include_context "with authenticated store"
      before(:each) do
        do_get_new
      end

      # Variables
      it "has current store" do
        subject.current_store.should_not be_nil
      end

      # Response
      it { should_not assign_to(:store) }
      it { should respond_with(:redirect) }
      it { should redirect_to(new_employee_session_path) }

      # Content
      it { should set_the_flash[:alert].to(/need to sign in or sign up/) }
    end
  end

  describe "#create", :create => true do
    context "as unauthenticated employee" do
      include_context "with unauthenticated employee"
      let(:attributes) { FactoryGirl.build(:store_attributes_hash).except(:organization) }

      before(:each) do
        do_post_create(attributes)
      end

      # Variables
      it "does not have current user" do
        subject.current_user.should be_nil
      end

      # Response
      it { should_not assign_to(:store) }
      it { should respond_with(:redirect) }
      it { should redirect_to(new_employee_session_path) }

      # Content
      it { should set_the_flash[:alert].to(/need to sign in or sign up/) }

      # Behavior
      it "should not create new Store" do
        Store.count.should eq(0)
      end
    end

    context "as authenticated employee" do
      include_context "with authenticated employee"
      
      context "with invalid attributes (invalid email)" do
        let(:attributes) { FactoryGirl.build(:store_attributes_hash, :email => "random.email.com", :email_confirmation => "random.email.com" ).except(:organization) }

        before(:each) do
          do_post_create(attributes)
        end
  
        # Variables
        it "has current employee" do
          subject.current_employee.should_not be_nil
        end

        # Response
        it { should assign_to(:store) }
        it { should respond_with(:success) }
  
        # Content
        it { should set_the_flash[:alert].to(/problem with some of your information/) }
        it { should render_template(:new) }

        # Behavior
        it "should not create new Store" do
          Store.count.should eq(0)
        end
      end

      context "with valid attributes" do
        let(:attributes) { FactoryGirl.build(:store_attributes_hash).except(:organization) }

        before(:each) do
          do_post_create(attributes)
        end
  
        # Variables
        it "has current employee" do
          subject.current_employee.should_not be_nil
        end

        # Response
        it { should assign_to(:store) }
        it { should respond_with(:redirect) }
        it { should redirect_to(employee_store_path(Store.last)) }
  
        # Content
        it { should set_the_flash[:notice].to(/Successfully created store/) }

        # Behavior
        it "should create new Store" do
          Store.count.should eq(1)
        end
      end
    end

    context "as authenticated customer" do
      include_context "with authenticated customer"
      let(:attributes) { FactoryGirl.build(:store_attributes_hash).except(:organization) }

      before(:each) do
        do_post_create(attributes)
      end

      # Variables
      it "has current customer" do
        subject.current_customer.should_not be_nil
      end

      # Response
      it { should_not assign_to(:store) }
      it { should respond_with(:redirect) }
      it { should redirect_to(new_employee_session_path) }

      # Content
      it { should set_the_flash[:alert].to(/need to sign in or sign up/) }
    end

    context "as authenticated store" do
      include_context "with authenticated store"
      let(:attributes) { FactoryGirl.build(:store_attributes_hash).except(:organization) }

      before(:each) do
        do_post_create(attributes)
      end

      # Variables
      it "has current store" do
        subject.current_store.should_not be_nil
      end

      # Response
      it { should_not assign_to(:store) }
      it { should respond_with(:redirect) }
      it { should redirect_to(new_employee_session_path) }

      # Content
      it { should set_the_flash[:alert].to(/need to sign in or sign up/) }
    end
  end

  describe "#show", :show => true do
    context "as unauthenticated employee" do
      include_context "with unauthenticated employee"
      let(:store) { FactoryGirl.create(:store) }

      before(:each) do
        do_get_show(store.id)
      end

      # Variables
      it "does not have current user" do
        subject.current_user.should be_nil
      end

      # Response
      it { should_not assign_to(:store) }
      it { should respond_with(:redirect) }
      it { should redirect_to(new_employee_session_path) }

      # Content
      it { should set_the_flash[:alert].to(/need to sign in or sign up/) }
    end
    
    context "as authenticated employee" do
      include_context "with authenticated employee"
      let(:store) { FactoryGirl.create(:store) }

      before(:each) do
        do_get_show(store.id)
      end

      # Variables
      it "has current employee" do
        subject.current_employee.should_not be_nil
      end

      # Response
      it { should assign_to(:store) }
      it { should respond_with(:success) }

      # Content
      it { should_not set_the_flash }
      it { should render_template(:show) }
    end

    context "as authenticated customer" do
      include_context "with authenticated customer"
      let(:store) { FactoryGirl.create(:store) }

      before(:each) do
        do_get_show(store.id)
      end

      # Variables
      it "has current customer" do
        subject.current_customer.should_not be_nil
      end

      # Response
      it { should_not assign_to(:store) }
      it { should respond_with(:redirect) }
      it { should redirect_to(new_employee_session_path) }

      # Content
      it { should set_the_flash[:alert].to(/need to sign in or sign up/) }
    end

    context "as authenticated store" do
      include_context "with authenticated store"
      let(:other_store) { FactoryGirl.create(:store) }

      before(:each) do
        do_get_show(other_store.id)
      end

      # Variables
      it "has current store" do
        subject.current_store.should_not be_nil
      end

      # Response
      it { should_not assign_to(:store) }
      it { should respond_with(:redirect) }
      it { should redirect_to(new_employee_session_path) }

      # Content
      it { should set_the_flash[:alert].to(/need to sign in or sign up/) }
    end
  end

  describe "#edit", :edit => true do
    context "as unauthenticated employee" do
      include_context "with unauthenticated employee"
      let(:store) { FactoryGirl.create(:store) }

      before(:each) do
        do_get_edit(store.id)
      end

      # Variables
      it "does not have current user" do
        subject.current_user.should be_nil
      end

      # Response
      it { should_not assign_to(:store) }
      it { should respond_with(:redirect) }
      it { should redirect_to(new_employee_session_path) }

      # Content
      it { should set_the_flash[:alert].to(/need to sign in or sign up/) }
    end
    
    context "as authenticated employee" do
      include_context "with authenticated employee"
      let(:store) { FactoryGirl.create(:store) }

      before(:each) do
        do_get_edit(store.id)
      end

      # Variables
      it "has current employee" do
        subject.current_employee.should_not be_nil
      end

      # Response
      it { should assign_to(:store) }
      it { should respond_with(:success) }

      # Content
      it { should_not set_the_flash }
      it { should render_template(:edit) }
    end

    context "as authenticated customer" do
      include_context "with authenticated customer"
      let(:store) { FactoryGirl.create(:store) }

      before(:each) do
        do_get_edit(store.id)
      end

      # Variables
      it "has current customer" do
        subject.current_customer.should_not be_nil
      end

      # Response
      it { should_not assign_to(:store) }
      it { should respond_with(:redirect) }
      it { should redirect_to(new_employee_session_path) }

      # Content
      it { should set_the_flash[:alert].to(/need to sign in or sign up/) }
    end

    context "as authenticated store" do
      include_context "with authenticated store"
      let(:other_store) { FactoryGirl.create(:store) }

      before(:each) do
        do_get_edit(store.id)
      end

      # Variables
      it "has current store" do
        subject.current_store.should_not be_nil
      end

      # Response
      it { should_not assign_to(:store) }
      it { should respond_with(:redirect) }
      it { should redirect_to(new_employee_session_path) }

      # Content
      it { should set_the_flash[:alert].to(/need to sign in or sign up/) }
    end
  end

  describe "#update", :update => true do
    context "as unauthenticated employee" do
      include_context "with unauthenticated employee"      
      let(:store) { FactoryGirl.create(:store) }
      let(:attributes) { { :name => "Gorilla Industries" } }

      before(:each) do
        do_put_update(store.id, attributes)
      end

      # Variables
      it "does not have current user" do
        subject.current_user.should be_nil
      end

      # Response
      it { should_not assign_to(:store) }
      it { should respond_with(:redirect) }
      it { should redirect_to(new_employee_session_path) }

      # Content
      it { should set_the_flash[:alert].to(/need to sign in or sign up/) }

      #Behavior
      it "should not update store" do
        store.reload
        store.name.should_not eq("Gorilla Industries")
      end
    end
    
    context "as authenticated employee" do
      include_context "with authenticated employee"

      context "with invalid attributes" do
        let(:store) { FactoryGirl.create(:store) }
        let(:attributes) { { :email => "notcredda.email.com", :email_confirmation => "notcredda.email.com" } }

        before(:each) do
          do_put_update(store.id, attributes)
        end

        # Variables
        it "has current employee" do
          subject.current_employee.should_not be_nil
        end

        # Response
        it { should assign_to(:store) }
        it { should respond_with(:success) }
  
        # Content
        it { should set_the_flash[:notice].to(/failed/) }
        it { should render_template(:edit) }

        #Behavior
        it "should not update store" do
          store.reload
          store.email.should_not eq("notcredda@email.com")
        end
      end

      context "with valid attributes (name)" do
        let(:store) { FactoryGirl.create(:store) }
        let(:attributes) { { :name => "Gorilla Industries" } }

        before(:each) do
          do_put_update(store.id, attributes)
        end

        # Variables
        it "has current employee" do
          subject.current_employee.should_not be_nil
        end

        # Response
        it { should assign_to(:store) }
        it { should respond_with(:redirect) }
        it { should redirect_to(employee_store_path(store)) }
  
        # Content
        it { should set_the_flash[:notice].to(/Successfully updated/) }
        
        #Behavior
        it "should update employee" do
          store.reload
          store.name.should eq("Gorilla Industries")
        end
      end

      context "with valid attributes (email)" do
        let(:store) { FactoryGirl.create(:store) }
        let(:attributes) { { :email => "new@notcredda.com", :email_confirmation => "new@notcredda.com" } }

        before(:each) do
          do_put_update(store.id, attributes)
        end

        # Variables
        it "has current employee" do
          subject.current_employee.should_not be_nil
        end

        # Response
        it { should assign_to(:store) }
        it { should respond_with(:redirect) }
        it { should redirect_to(employee_store_path(store)) }
  
        # Content
        it { should set_the_flash[:notice].to(/Successfully updated/) }
        
        #Behavior
        it "should update employee unconfirmed email" do
          store.reload
          store.unconfirmed_email.should eq("new@notcredda.com")
        end

        it "should send confirmation email" do
          confirmation_email_sent_to?(attributes[:email]).should be_true
        end
      end
    end

    context "as authenticated customer" do
      include_context "with authenticated customer"
      let(:store) { FactoryGirl.create(:store) }
      let(:attributes) { { :name => "Gorilla Industries" } }

      before(:each) do
        do_put_update(store.id, attributes)
      end

      # Variables
      it "has current customer" do
        subject.current_customer.should_not be_nil
      end

      # Response
      it { should_not assign_to(:store) }
      it { should respond_with(:redirect) }
      it { should redirect_to(new_employee_session_path) }

      # Content
      it { should set_the_flash[:alert].to(/need to sign in or sign up/) }
    end

    context "as authenticated store" do
      include_context "with authenticated store"
      let(:other_store) { FactoryGirl.create(:store) }
      let(:attributes) { { :first_name => "Gorilla Industries" } }

      before(:each) do
        do_put_update(other_store.id, attributes)
      end

      # Variables
      it "has current store" do
        subject.current_store.should_not be_nil
      end

      # Response
      it { should_not assign_to(:store) }
      it { should respond_with(:redirect) }
      it { should redirect_to(new_employee_session_path) }

      # Content
      it { should set_the_flash[:alert].to(/need to sign in or sign up/) }
    end
  end

  describe "#destroy", :destroy => true do
    context "as unauthenticated employee" do
      include_context "with unauthenticated employee"
      let(:store) { FactoryGirl.create(:store) }

      before(:each) do
        do_delete_destroy(store.id)
      end

      # Variables
      it "does not have current user" do
        subject.current_user.should be_nil
      end

      # Response
      it { should_not assign_to(:store) }
      it { should respond_with(:redirect) }
      it { should redirect_to(new_employee_session_path) }

      # Content
      it { should set_the_flash[:alert].to(/need to sign in or sign up/) }

      # Behavior
      it "should persist Store" do
        expect { store.reload }.to_not raise_error
      end

      it "should not cancel store" do
        store.cancelled?.should be_false
      end
    end
    
    context "as authenticated employee" do
      include_context "with authenticated employee"
      let(:store) { FactoryGirl.create(:store) }

      before(:each) do
        do_delete_destroy(store.id)
      end

      # Variables
      it "has current_employee" do
        subject.current_employee.should_not be_nil
      end

      # Response
      it { should assign_to(:store) }
      it { should respond_with(:redirect) }
      it { should redirect_to(employee_stores_path) }

      # Content
      it { should set_the_flash[:notice].to(/Successfully cancelled/) }

      # Behavior
      it "should persist Store" do
        expect { store.reload }.to_not raise_error
      end

      it "should cancel store" do
        store.reload
        store.cancelled?.should be_true
      end
    end

    context "as authenticated customer" do
      include_context "with authenticated customer"
      let(:store) { FactoryGirl.create(:store) }

      before(:each) do
        do_delete_destroy(store.id)
      end

      # Variables
      it "has current customer" do
        subject.current_customer.should_not be_nil
      end

      # Response
      it { should_not assign_to(:store) }
      it { should respond_with(:redirect) }
      it { should redirect_to(new_employee_session_path) }

      # Content
      it { should set_the_flash[:alert].to(/need to sign in or sign up/) }

      # Behavior
      it "should persist Store" do
        expect { store.reload }.to_not raise_error
      end

      it "should not cancel store" do
        store.reload
        store.cancelled?.should be_false
      end
    end

    context "as authenticated store" do
      include_context "with authenticated store"
      let(:other_store) { FactoryGirl.create(:store) }

      before(:each) do
        do_delete_destroy(store.id)
      end

      # Variables
      it "has current store" do
        subject.current_store.should_not be_nil
      end

      # Response
      it { should_not assign_to(:store) }
      it { should respond_with(:redirect) }
      it { should redirect_to(new_employee_session_path) }

      # Content
      it { should set_the_flash[:alert].to(/need to sign in or sign up/) }

      # Behavior
      it "should persist Store" do
        expect { store.reload }.to_not raise_error
      end

      it "should not cancel store" do
        store.reload
        store.cancelled?.should be_false
      end
    end
  end
end