require 'spec_helper'

describe Store::ApplicationsController do
  # Controller Specific Shared Contexts
  #----------------------------------------------------------------------------
  shared_context "with current_store applications" do
    let!(:application_1) { FactoryGirl.create(:unclaimed_application, :store_account_number => store.account_number) }
    let!(:application_2) { FactoryGirl.create(:unclaimed_application, :store_account_number => store.account_number) }
    let!(:application_3) { FactoryGirl.create(:unclaimed_application) }
    let!(:application_4) { FactoryGirl.create(:unclaimed_application) }
  end

  shared_context "with random applications" do
    let!(:application_1) { FactoryGirl.create(:unclaimed_application) }
    let!(:application_2) { FactoryGirl.create(:unclaimed_application) }
    let!(:application_3) { FactoryGirl.create(:unclaimed_application) }
    let!(:application_4) { FactoryGirl.create(:unclaimed_application) }
  end

  # Controller Shared Methods
  #----------------------------------------------------------------------------
  def do_get_index
    get :index, :format => 'html'
  end

  def do_get_new
    get :new, :format => 'html'
  end

  def do_post_create(attributes)
    post :create, :application => attributes, :format => 'html'
  end

  def do_get_edit(id)
    get :edit, :id => id,:format => 'html'
  end
  
  def do_put_update(id, attributes)
    put :update, :id => id, :application => attributes, :format => 'html'
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
    it { should route(:get, "/store/applications").to(:action => :index) }
    it { should route(:get, "/store/applications/new").to(:action => :new) }
    it { should route(:post, "/store/applications").to(:action => :create) }
    it { should route(:get, "/store/applications/1").to(:action => :show, :id => 1) }
    it { should route(:get, "/store/applications/1/edit").to(:action => :edit, :id => 1) }
    it { should route(:put, "/store/applications/1").to(:action => :update, :id => 1) }
    it { should route(:delete, "/store/applications/1").to(:action => :destroy, :id => 1) }
  end

  # Methods
  #----------------------------------------------------------------------------
  describe "#index", :index => true do
    context "as unauthenticated store" do
      include_context "with unauthenticated store"
      before(:each) do
        do_get_index
      end

      # Variables
      it "does not have current user" do
        subject.current_user.should be_nil
      end

      # Response
      it { should_not assign_to(:applications) }
      it { should respond_with(:redirect) }
      it { should redirect_to(new_store_session_path) }

      # Content
      it { should set_the_flash[:alert].to(/need to sign in or sign up/) }
    end

    context "as authenticated store" do
      include_context "with authenticated store"
      
      context "with no applications" do
        include_context "with random applications"
        
        before(:each) do
          do_get_index
        end
  
        # Variables
        it "has current store" do
          subject.current_store.should_not be_nil
        end
  
        # Response
        it { should assign_to(:applications).with([]) }
        it { should respond_with(:success) }
  
        # Content
        it { should_not set_the_flash }
        it { should render_template(:index) }
      end

      context "with applications" do
        include_context "with current_store applications"
      
        before(:each) do
          do_get_index
        end
  
        # Variables
        it "has current store" do
          subject.current_store.should_not be_nil
        end
  
        # Response
        it { should assign_to(:applications).with([application_1, application_2]) }
        it { should respond_with(:success) }
  
        # Content
        it { should_not set_the_flash }
        it { should render_template(:index) }
      end
    end

    context "as authenticated customer" do
      include_context "with authenticated customer"
      before(:each) do
        do_get_index
      end

      # Variables
      it "has current customer" do
        subject.current_customer.should_not be_nil
      end

      # Response
      it { should_not assign_to(:applications) }
      it { should respond_with(:redirect) }
      it { should redirect_to(new_store_session_path) }

      # Content
      it { should set_the_flash[:alert].to(/need to sign in or sign up/) }
    end

    context "as authenticated employee" do
      include_context "with authenticated employee"
      before(:each) do
        do_get_index
      end

      # Variables
      it "has current employee" do
        subject.current_employee.should_not be_nil
      end

      # Response
      it { should_not assign_to(:applications) }
      it { should respond_with(:redirect) }
      it { should redirect_to(new_store_session_path) }

      # Content
      it { should set_the_flash[:alert].to(/need to sign in or sign up/) }
    end
  end

  describe "#new", :new => true do
    context "as unauthenticated store" do
      include_context "with unauthenticated store"
      before(:each) do
        do_get_new
      end

      # Variables
      it "does not have current user" do
        subject.current_user.should be_nil
      end

      # Response
      it { should_not assign_to(:application) }
      it { should respond_with(:redirect) }
      it { should redirect_to(new_store_session_path) }

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
      it { should assign_to(:application).with_kind_of(Application) }
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
      it { should_not assign_to(:application) }
      it { should respond_with(:redirect) }
      it { should redirect_to(new_store_session_path) }

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
      it { should_not assign_to(:application) }
      it { should respond_with(:redirect) }
      it { should redirect_to(new_store_session_path) }

      # Content
      it { should set_the_flash[:alert].to(/need to sign in or sign up/) }
    end
  end

  describe "#create", :create => true do
    context "as unauthenticated store" do
      include_context "with unauthenticated store"
      let(:attributes) { FactoryGirl.build(:application_attributes_hash) }

      before(:each) do
        do_post_create(attributes)
      end

      # Variables
      it "does not have current user" do
        subject.current_user.should be_nil
      end

      # Response
      it { should_not assign_to(:application) }
      it { should respond_with(:redirect) }
      it { should redirect_to(new_store_session_path) }

      # Content
      it { should set_the_flash[:alert].to(/need to sign in or sign up/) }

      # Behavior
      it "should not create new Application" do
        Application.count.should eq(0)
      end
    end

    context "as authenticated store" do
      include_context "with authenticated store"
      
      context "with invalid attributes (no matching email)" do
        let(:attributes) { FactoryGirl.build(:application_attributes_hash).except(:matching_email) }

        before(:each) do
          do_post_create(attributes)
        end
  
        # Variables
        it "has current store" do
          subject.current_store.should_not be_nil
        end

        # Response
        it { should assign_to(:application).with_kind_of(Application) }
        it { should respond_with(:success) }
  
        # Content
        it { should set_the_flash[:alert].to(/problem with some of your information/) }
        it { should render_template(:new) }

        # Behavior
        it "should not create new Application" do
          Application.count.should eq(0)
        end
      end

      context "with valid attributes" do
        let(:attributes) { FactoryGirl.build(:application_attributes_hash) }

        before(:each) do
          do_post_create(attributes)
        end
  
        # Variables
        it "has current store" do
          subject.current_store.should_not be_nil
        end

        # Response
        it { should assign_to(:application).with_kind_of(Application) }
        it { should respond_with(:redirect) }
        it { should redirect_to(store_application_path(Application.last)) }
  
        # Content
        it { should set_the_flash[:notice].to(/Successfully started application/) }

        # Behavior
        it "should create new Application" do
          Application.count.should eq(1)
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
      it { should_not assign_to(:application) }
      it { should respond_with(:redirect) }
      it { should redirect_to(new_store_session_path) }

      # Content
      it { should set_the_flash[:alert].to(/need to sign in or sign up/) }

      # Behavior
      it "should not create new Store" do
        Application.count.should eq(0)
      end
    end

    context "as authenticated employee" do
      include_context "with authenticated employee"
      let(:attributes) { FactoryGirl.build(:application_attributes_hash) }

      before(:each) do
        do_post_create(attributes)
      end

      # Variables
      it "has current employee" do
        subject.current_employee.should_not be_nil
      end

      # Response
      it { should_not assign_to(:application) }
      it { should respond_with(:redirect) }
      it { should redirect_to(new_store_session_path) }

      # Content
      it { should set_the_flash[:alert].to(/need to sign in or sign up/) }

      # Behavior
      it "should not create new Application" do
        Application.count.should eq(0)
      end
    end
  end

  describe "#show", :show => true do
    context "as unauthenticated store" do
      include_context "with unauthenticated store"
      let(:application) { FactoryGirl.create(:unclaimed_application) }

      before(:each) do
        do_get_show(application.id)
      end

      # Variables
      it "does not have current user" do
        subject.current_user.should be_nil
      end

      # Response
      it { should_not assign_to(:application) }
      it { should respond_with(:redirect) }
      it { should redirect_to(new_store_session_path) }

      # Content
      it { should set_the_flash[:alert].to(/need to sign in or sign up/) }
    end
    
    context "as authenticated store" do
      include_context "with authenticated store"

      context "with another store's application" do
        include_context "with random applications"

        before(:each) do
          do_get_show(application_1.id)
        end
  
        # Variables
        it "has current store" do
          subject.current_store.should_not be_nil
        end
  
        # Response
        it { should assign_to(:application).with(application_1) }
        it { should respond_with(:redirect) }
        it { should redirect_to(store_home_path)}
  
        # Content
        it { should set_the_flash[:alert].to(/Access denied/) }
      end

      context "with store's application" do
        include_context "with current_store applications"

        before(:each) do
          do_get_show(application_1.id)
        end
  
        # Variables
        it "has current store" do
          subject.current_store.should_not be_nil
        end
  
        # Response
        it { should assign_to(:application).with(application_1) }
        it { should respond_with(:success) }
  
        # Content
        it { should_not set_the_flash }
        it { should render_template(:show) }
      end
    end

    context "as authenticated customer" do
      include_context "with authenticated customer"
      let(:application) { FactoryGirl.create(:unclaimed_application) }

      before(:each) do
        do_get_show(application.id)
      end

      # Variables
      it "has current customer" do
        subject.current_customer.should_not be_nil
      end

      # Response
      it { should_not assign_to(:application) }
      it { should respond_with(:redirect) }
      it { should redirect_to(new_store_session_path) }

      # Content
      it { should set_the_flash[:alert].to(/need to sign in or sign up/) }
    end

    context "as authenticated employee" do
      include_context "with authenticated employee"
      let(:application) { FactoryGirl.create(:unclaimed_application) }

      before(:each) do
        do_get_show(application.id)
      end

      # Variables
      it "has current employee" do
        subject.current_employee.should_not be_nil
      end

      # Response
      it { should_not assign_to(:application) }
      it { should respond_with(:redirect) }
      it { should redirect_to(new_store_session_path) }

      # Content
      it { should set_the_flash[:alert].to(/need to sign in or sign up/) }
    end
  end

  describe "#edit", :edit => true do
    context "as unauthenticated store" do
      include_context "with unauthenticated store"
      let(:application) { FactoryGirl.create(:unclaimed_application) }

      before(:each) do
        do_get_edit(application.id)
      end

      # Variables
      it "does not have current user" do
        subject.current_user.should be_nil
      end

      # Response
      it { should_not assign_to(:application) }
      it { should respond_with(:redirect) }
      it { should redirect_to(new_store_session_path) }

      # Content
      it { should set_the_flash[:alert].to(/need to sign in or sign up/) }
    end
    
    context "as authenticated store" do
      include_context "with authenticated store"

      context "with another store's application" do
        include_context "with random applications"

        before(:each) do
          do_get_edit(application_1.id)
        end
  
        # Variables
        it "has current store" do
          subject.current_store.should_not be_nil
        end
  
        # Response
        it { should assign_to(:application).with(application_1) }
        it { should respond_with(:redirect) }
  
        # Content
        it { should set_the_flash[:alert].to(/Access denied/) }
      end

      context "with store's application" do
        include_context "with current_store applications"

        before(:each) do
          do_get_edit(application_1.id)
        end
  
        # Variables
        it "has current store" do
          subject.current_store.should_not be_nil
        end
  
        # Response
        it { should assign_to(:application).with(application_1) }
        it { should respond_with(:success) }
  
        # Content
        it { should_not set_the_flash }
        it { should render_template(:edit) }
      end
    end

    context "as authenticated customer" do
      include_context "with authenticated customer"
      let(:application) { FactoryGirl.create(:unclaimed_application) }

      before(:each) do
        do_get_edit(application.id)
      end

      # Variables
      it "has current customer" do
        subject.current_customer.should_not be_nil
      end

      # Response
      it { should_not assign_to(:application) }
      it { should respond_with(:redirect) }
      it { should redirect_to(new_store_session_path) }

      # Content
      it { should set_the_flash[:alert].to(/need to sign in or sign up/) }
    end

    context "as authenticated employee" do
      include_context "with authenticated employee"
      let(:application) { FactoryGirl.create(:unclaimed_application) }

      before(:each) do
        do_get_edit(application.id)
      end

      # Variables
      it "has current employee" do
        subject.current_employee.should_not be_nil
      end

      # Response
      it { should_not assign_to(:application) }
      it { should respond_with(:redirect) }
      it { should redirect_to(new_store_session_path) }

      # Content
      it { should set_the_flash[:alert].to(/need to sign in or sign up/) }
    end
  end

  describe "#update", :update => true do
    context "as unauthenticated store" do
      include_context "with unauthenticated store"
      let(:application) { FactoryGirl.create(:unclaimed_application) }
      let(:attributes) { { :matching_email => "new@email.com" } }

      before(:each) do
        do_put_update(application.id, attributes)
      end

      # Variables
      it "does not have current user" do
        subject.current_user.should be_nil
      end

      # Response
      it { should_not assign_to(:application) }
      it { should respond_with(:redirect) }
      it { should redirect_to(new_store_session_path) }

      # Content
      it { should set_the_flash[:alert].to(/need to sign in or sign up/) }

      #Behavior
      it "should not update application" do
        application.reload
        application.matching_email.should_not eq("new@email.com")
      end
    end
    
    context "as authenticated store" do
      include_context "with authenticated store"

      context "with another store's application" do
        include_context "with random applications"  

        context "with invalid attributes" do
          let(:attributes) { { :matching_email => nil } }
  
          before(:each) do
            do_put_update(application_1.id, attributes)
          end
  
          # Variables
          it "has current store" do
            subject.current_store.should_not be_nil
          end
  
          # Response
          it { should assign_to(:application).with_kind_of(Application) }
          it { should respond_with(:redirect) }
          it { should redirect_to(store_home_path) }
    
          # Content
          it { should set_the_flash[:alert].to(/Access denied/) }
  
          #Behavior
          it "should not update application" do
            application_1.reload
            application_1.matching_email.should_not eq("new@email.com")
          end
        end
  
        context "with valid attributes" do
          let(:attributes) { { :matching_email => "new@email.com" } }
  
          before(:each) do
            do_put_update(application_1.id, attributes)
          end
  
          # Variables
          it "has current store" do
            subject.current_store.should_not be_nil
          end
  
          # Response
          it { should assign_to(:application).with_kind_of(Application) }
          it { should respond_with(:redirect) }
          it { should redirect_to(store_home_path) }
    
          # Content
          it { should set_the_flash[:alert].to(/Access denied/) }
          
          #Behavior
          it "should not update application" do
            application_1.reload
            application_1.matching_email.should_not eq("new@email.com")
          end
        end
      end
      
      context "with store's application" do
        include_context "with current_store applications"  

        context "with invalid attributes" do
          let(:attributes) { { :matching_email => nil } }
  
          before(:each) do
            do_put_update(application_1.id, attributes)
          end
  
          # Variables
          it "has current store" do
            subject.current_store.should_not be_nil
          end
  
          # Response
          it { should assign_to(:application).with_kind_of(Application) }
          it { should respond_with(:success) }
    
          # Content
          it { should set_the_flash[:notice].to(/failed/) }
          it { should render_template(:edit) }
  
          #Behavior
          it "should not update application" do
            application_1.reload
            application_1.matching_email.should_not eq("new@email.com")
          end
        end
  
        context "with valid attributes" do
          let(:attributes) { { :matching_email => "new@email.com" } }
  
          before(:each) do
            do_put_update(application_1.id, attributes)
          end
  
          # Variables
          it "has current store" do
            subject.current_store.should_not be_nil
          end
  
          # Response
          it { should assign_to(:application).with_kind_of(Application) }
          it { should respond_with(:redirect) }
          it { should redirect_to(store_application_path(application_1)) }
    
          # Content
          it { should set_the_flash[:notice].to(/Successfully updated/) }
          
          #Behavior
          it "should update application" do
            application_1.reload
            application_1.matching_email.should eq("new@email.com")
          end
        end
      end
    end

    context "as authenticated customer" do
      include_context "with authenticated customer"
      let(:application) { FactoryGirl.create(:unclaimed_application) }
      let(:attributes) { { :matching_email => "new@email.com" } }

      before(:each) do
        do_put_update(application.id, attributes)
      end

      # Variables
      it "has current customer" do
        subject.current_customer.should_not be_nil
      end

      # Response
      it { should_not assign_to(:application) }
      it { should respond_with(:redirect) }
      it { should redirect_to(new_store_session_path) }

      # Content
      it { should set_the_flash[:alert].to(/need to sign in or sign up/) }
    end

    context "as authenticated employee" do
      include_context "with authenticated employee"
      let(:application) { FactoryGirl.create(:unclaimed_application) }
      let(:attributes) { { :matching_email => "new@email.com" } }

      before(:each) do
        do_put_update(application.id, attributes)
      end

      # Variables
      it "has current employee" do
        subject.current_employee.should_not be_nil
      end

      # Response
      it { should_not assign_to(:application) }
      it { should respond_with(:redirect) }
      it { should redirect_to(new_store_session_path) }

      # Content
      it { should set_the_flash[:alert].to(/need to sign in or sign up/) }
    end
  end

  describe "#destroy", :destroy => true do
    context "as unauthenticated store" do
      include_context "with unauthenticated store"
      let(:application) { FactoryGirl.create(:unclaimed_application) }

      before(:each) do
        do_delete_destroy(application.id)
      end

      # Variables
      it "does not have current user" do
        subject.current_user.should be_nil
      end

      # Response
      it { should_not assign_to(:application) }
      it { should respond_with(:redirect) }
      it { should redirect_to(new_store_session_path) }

      # Content
      it { should set_the_flash[:alert].to(/need to sign in or sign up/) }

      # Behavior
      it "should persist Application" do
        expect { application.reload }.to_not raise_error
      end
    end
    
    context "as authenticated store" do
      include_context "with authenticated store"

      context "with another store's application" do
        include_context "with random applications"  

        before(:each) do
          do_delete_destroy(application_1.id)
        end
  
        # Variables
        it "has current_store" do
          subject.current_store.should_not be_nil
        end
  
        # Response
        it { should assign_to(:application).with(application_1) }
        it { should respond_with(:redirect) }
        it { should redirect_to(store_home_path) }
  
        # Content
        it { should set_the_flash[:alert].to(/Access denied/) }
  
        # Behavior
        it "should persist Application" do
          expect { application_1.reload }.to_not raise_error
        end
      end

      context "with store's application" do
        include_context "with current_store applications"  

        before(:each) do
          do_delete_destroy(application_1.id)
        end
  
        # Variables
        it "has current_store" do
          subject.current_store.should_not be_nil
        end
  
        # Response
        it { should assign_to(:application).with(application_1) }
        it { should respond_with(:redirect) }
        it { should redirect_to(store_applications_path) }
  
        # Content
        it { should set_the_flash[:notice].to(/Successfully destroyed/) }
  
        # Behavior
        it "should not persist Application" do
          expect { application_1.reload }.to raise_error
        end
      end
    end

    context "as authenticated customer" do
      include_context "with authenticated customer"
      let(:application) { FactoryGirl.create(:unclaimed_application) }

      before(:each) do
        do_delete_destroy(application.id)
      end

      # Variables
      it "has current customer" do
        subject.current_customer.should_not be_nil
      end

      # Response
      it { should_not assign_to(:application) }
      it { should respond_with(:redirect) }
      it { should redirect_to(new_store_session_path) }

      # Content
      it { should set_the_flash[:alert].to(/need to sign in or sign up/) }

      # Behavior
      it "should persist Application" do
        expect { application.reload }.to_not raise_error
      end
    end

    context "as authenticated employee" do
      include_context "with authenticated employee"
      let(:application) { FactoryGirl.create(:unclaimed_application) }

      before(:each) do
        do_delete_destroy(application.id)
      end

      # Variables
      it "has current employee" do
        subject.current_employee.should_not be_nil
      end

      # Response
      it { should_not assign_to(:application) }
      it { should respond_with(:redirect) }
      it { should redirect_to(new_store_session_path) }

      # Content
      it { should set_the_flash[:alert].to(/need to sign in or sign up/) }

      # Behavior
      it "should persist Application" do
        expect { application.reload }.to_not raise_error
      end
    end
  end
end