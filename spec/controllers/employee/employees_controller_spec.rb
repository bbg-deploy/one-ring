require 'spec_helper'

describe Employee::EmployeesController do
  # Controller Shared Methods
  #----------------------------------------------------------------------------
  def do_get_new
    get :new, :format => 'html'
  end

  def do_post_create(attributes)
    post :create, :employee => attributes, :format => 'html'
  end

  def do_get_edit(id)
    get :edit, :id => id,:format => 'html'
  end
  
  def do_put_update(id, attributes)
    put :update, :id => id, :employee => attributes, :format => 'html'
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
    it { should route(:get, "/employee/employees").to(:action => :index) }
    it { should route(:get, "/employee/employees/new").to(:action => :new) }
    it { should route(:post, "/employee/employees").to(:action => :create) }
    it { should route(:get, "/employee/employees/1").to(:action => :show, :id => 1) }
    it { should route(:get, "/employee/employees/1/edit").to(:action => :edit, :id => 1) }
    it { should route(:put, "/employee/employees/1").to(:action => :update, :id => 1) }
    it { should route(:delete, "/employee/employees/1").to(:action => :destroy, :id => 1) }
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
      it { should_not assign_to(:employee) }
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
      it { should assign_to(:employee) }
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
      it { should_not assign_to(:employee) }
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
      it { should_not assign_to(:employee) }
      it { should respond_with(:redirect) }
      it { should redirect_to(new_employee_session_path) }

      # Content
      it { should set_the_flash[:alert].to(/need to sign in or sign up/) }
    end
  end

  describe "#create", :create => true do
    context "as unauthenticated employee" do
      include_context "with unauthenticated employee"
      let(:attributes) { FactoryGirl.build(:employee_attributes_hash) }
      before(:each) do
        do_post_create(attributes)
      end

      # Variables
      it "does not have current user" do
        subject.current_user.should be_nil
      end

      # Response
      it { should_not assign_to(:employee) }
      it { should respond_with(:redirect) }
      it { should redirect_to(new_employee_session_path) }

      # Content
      it { should set_the_flash[:alert].to(/need to sign in or sign up/) }

      # Behavior
      it "should not create new Employee" do
        Employee.count.should eq(0)
      end
    end

    context "as authenticated employee" do
      include_context "with authenticated employee"
      
      context "with invalid attributes (non-credda email)" do
        let(:attributes) { FactoryGirl.build(:employee_attributes_hash, :email => "random@email.com", :email_confirmation => "random@email.com" ) }

        before(:each) do
          do_post_create(attributes)
        end
  
        # Variables
        it "has current employee" do
          subject.current_employee.should_not be_nil
        end

        # Response
        it { should assign_to(:employee) }
        it { should respond_with(:success) }
  
        # Content
        it { should set_the_flash[:alert].to(/problem with some of your information/) }
        it { should render_template(:new) }

        # Behavior
        it "should not create new Employee" do
          Employee.count.should eq(1)
        end
      end

      context "with valid attributes" do
        let(:attributes) { FactoryGirl.build(:employee_attributes_hash) }

        before(:each) do
          do_post_create(attributes)
        end
  
        # Variables
        it "has current employee" do
          subject.current_employee.should_not be_nil
        end

        # Response
        it { should assign_to(:employee) }
        it { should respond_with(:redirect) }
        it { should redirect_to(employee_employee_path(Employee.last)) }
  
        # Content
        it { should set_the_flash[:notice].to(/Successfully created employee/) }

        # Behavior
        it "should create new Employee" do
          Employee.count.should eq(2)
        end
      end
    end

    context "as authenticated customer" do
      include_context "with authenticated customer"
      let(:attributes) { FactoryGirl.build(:employee_attributes_hash) }

      before(:each) do
        do_post_create(attributes)
      end

      # Variables
      it "has current customer" do
        subject.current_customer.should_not be_nil
      end

      # Response
      it { should_not assign_to(:employee) }
      it { should respond_with(:redirect) }
      it { should redirect_to(new_employee_session_path) }

      # Content
      it { should set_the_flash[:alert].to(/need to sign in or sign up/) }
    end

    context "as authenticated store" do
      include_context "with authenticated store"
      let(:attributes) { FactoryGirl.build(:employee_attributes_hash) }

      before(:each) do
        do_post_create(attributes)
      end

      # Variables
      it "has current store" do
        subject.current_store.should_not be_nil
      end

      # Response
      it { should_not assign_to(:employee) }
      it { should respond_with(:redirect) }
      it { should redirect_to(new_employee_session_path) }

      # Content
      it { should set_the_flash[:alert].to(/need to sign in or sign up/) }
    end
  end

  describe "#show", :show => true do
    context "as unauthenticated employee" do
      include_context "with unauthenticated employee"
      let(:other_employee) { FactoryGirl.create(:employee) }

      before(:each) do
        do_get_show(other_employee.id)
      end

      # Variables
      it "does not have current user" do
        subject.current_user.should be_nil
      end

      # Response
      it { should_not assign_to(:employee) }
      it { should respond_with(:redirect) }
      it { should redirect_to(new_employee_session_path) }

      # Content
      it { should set_the_flash[:alert].to(/need to sign in or sign up/) }
    end
    
    context "as authenticated employee" do
      include_context "with authenticated employee"

      context "with employee's own record" do
        before(:each) do
          do_get_show(employee.id)
        end

        # Variables
        it "has current employee" do
          subject.current_employee.should_not be_nil
        end

        # Response
        it { should assign_to(:employee) }
        it { should respond_with(:success) }
  
        # Content
        it { should_not set_the_flash }
        it { should render_template(:show) }
      end

      context "with other employee's record" do
        let(:other_employee) { FactoryGirl.create(:employee) }

        before(:each) do
          do_get_show(other_employee.id)
        end

        # Variables
        it "has current employee" do
          subject.current_employee.should_not be_nil
        end

        # Response
        it { should assign_to(:employee) }
        it { should respond_with(:success) }
  
        # Content
        it { should_not set_the_flash }
        it { should render_template(:show) }
      end
    end

    context "as authenticated customer" do
      include_context "with authenticated customer"
      let(:employee) { FactoryGirl.create(:employee) }

      before(:each) do
        do_get_show(employee.id)
      end

      # Variables
      it "has current customer" do
        subject.current_customer.should_not be_nil
      end

      # Response
      it { should_not assign_to(:employee) }
      it { should respond_with(:redirect) }
      it { should redirect_to(new_employee_session_path) }

      # Content
      it { should set_the_flash[:alert].to(/need to sign in or sign up/) }
    end

    context "as authenticated store" do
      include_context "with authenticated store"
      let(:employee) { FactoryGirl.create(:employee) }

      before(:each) do
        do_get_show(employee.id)
      end

      # Variables
      it "has current store" do
        subject.current_store.should_not be_nil
      end

      # Response
      it { should_not assign_to(:employee) }
      it { should respond_with(:redirect) }
      it { should redirect_to(new_employee_session_path) }

      # Content
      it { should set_the_flash[:alert].to(/need to sign in or sign up/) }
    end
  end

  describe "#edit", :edit => true do
    context "as unauthenticated employee" do
      include_context "with unauthenticated employee"
      let(:other_employee) { FactoryGirl.create(:employee) }

      before(:each) do
        do_get_edit(other_employee.id)
      end

      # Variables
      it "does not have current user" do
        subject.current_user.should be_nil
      end

      # Response
      it { should_not assign_to(:employee) }
      it { should respond_with(:redirect) }
      it { should redirect_to(new_employee_session_path) }

      # Content
      it { should set_the_flash[:alert].to(/need to sign in or sign up/) }
    end
    
    context "as authenticated employee" do
      include_context "with authenticated employee"

      context "with employee's own record" do
        before(:each) do
          do_get_edit(employee.id)
        end

        # Variables
        it "has current employee" do
          subject.current_employee.should_not be_nil
        end

        # Response
        it { should assign_to(:employee) }
        it { should respond_with(:success) }
  
        # Content
        it { should_not set_the_flash }
        it { should render_template(:edit) }
      end

      describe "with other employee's record" do
        let(:other_employee) { FactoryGirl.create(:employee) }

        before(:each) do
          do_get_edit(other_employee.id)
        end

        # Variables
        it "has current employee" do
          subject.current_employee.should_not be_nil
        end

        # Response
        it { should assign_to(:employee) }
        it { should respond_with(:success) }
  
        # Content
        it { should_not set_the_flash }
        it { should render_template(:edit) }
      end
    end

    context "as authenticated customer" do
      include_context "with authenticated customer"
      let(:employee) { FactoryGirl.create(:employee) }

      before(:each) do
        do_get_edit(employee.id)
      end

      # Variables
      it "has current customer" do
        subject.current_customer.should_not be_nil
      end

      # Response
      it { should_not assign_to(:employee) }
      it { should respond_with(:redirect) }
      it { should redirect_to(new_employee_session_path) }

      # Content
      it { should set_the_flash[:alert].to(/need to sign in or sign up/) }
    end

    context "as authenticated store" do
      include_context "with authenticated store"
      let(:employee) { FactoryGirl.create(:employee) }

      before(:each) do
        do_get_edit(employee.id)
      end

      # Variables
      it "has current store" do
        subject.current_store.should_not be_nil
      end

      # Response
      it { should_not assign_to(:employee) }
      it { should respond_with(:redirect) }
      it { should redirect_to(new_employee_session_path) }

      # Content
      it { should set_the_flash[:alert].to(/need to sign in or sign up/) }
    end
  end

  describe "#update", :update => true do
    context "as unauthenticated employee" do
      include_context "with unauthenticated employee"      
      let(:other_employee) { FactoryGirl.create(:employee) }
      let(:attributes) { { :first_name => "Billy" } }

      before(:each) do
        do_put_update(other_employee.id, attributes)
      end

      # Variables
      it "does not have current user" do
        subject.current_user.should be_nil
      end

      # Response
      it { should_not assign_to(:employee) }
      it { should respond_with(:redirect) }
      it { should redirect_to(new_employee_session_path) }

      # Content
      it { should set_the_flash[:alert].to(/need to sign in or sign up/) }

      #Behavior
      it "should not update payment profile" do
        other_employee.reload
        other_employee.first_name.should_not eq("Billy")
      end
    end
    
    context "as authenticated employee" do
      include_context "with authenticated employee"

      context "with employee's own record" do
        context "with invalid attributes" do
          let(:attributes) { { :email => "notcredda@email.com", :email_confirmation => "notcredda@email.com" } }

          before(:each) do
            do_put_update(employee.id, attributes)
          end
  
          # Variables
          it "has current employee" do
            subject.current_employee.should_not be_nil
          end

          # Response
          it { should assign_to(:employee) }
          it { should respond_with(:success) }
    
          # Content
          it { should set_the_flash[:notice].to(/failed/) }
          it { should render_template(:edit) }

          #Behavior
          it "should not update employee" do
            employee.reload
            employee.email.should_not eq("notcredda@email.com")
          end
        end

        context "with valid attributes (name)" do
          let(:attributes) { { :first_name => "Billy" } }

          before(:each) do
            do_put_update(employee.id, attributes)
          end
  
          # Variables
          it "has current employee" do
            subject.current_employee.should_not be_nil
          end

          # Response
          it { should assign_to(:employee) }
          it { should respond_with(:redirect) }
          it { should redirect_to(employee_employee_path(employee)) }
    
          # Content
          it { should set_the_flash[:notice].to(/Successfully updated/) }
          
          #Behavior
          it "should update employee" do
            employee.reload
            employee.first_name.should eq("Billy")
          end
        end

        context "with valid attributes (email)" do
          let(:attributes) { { :email => "new@credda.com", :email_confirmation => "new@credda.com" } }

          before(:each) do
            do_put_update(employee.id, attributes)
          end
  
          # Variables
          it "has current employee" do
            subject.current_employee.should_not be_nil
          end

          # Response
          it { should assign_to(:employee) }
          it { should respond_with(:redirect) }
          it { should redirect_to(employee_employee_path(employee)) }
    
          # Content
          it { should set_the_flash[:notice].to(/Successfully updated/) }
          
          #Behavior
          it "should update employee unconfirmed email" do
            employee.reload
            employee.unconfirmed_email.should eq("new@credda.com")
          end

          it "should send confirmation email" do
            confirmation_email_sent_to?(attributes[:email]).should be_true
          end
        end
      end

      describe "with other employee's record" do
        context "with invalid attributes" do
          let(:other_employee) { FactoryGirl.create(:employee) }
          let(:attributes) { { :email => "notcredda@email.com", :email_confirmation => "notcredda@email.com" } }

          before(:each) do
            do_put_update(other_employee.id, attributes)
          end
  
          # Variables
          it "has current employee" do
            subject.current_employee.should_not be_nil
          end

          # Response
          it { should assign_to(:employee) }
          it { should respond_with(:success) }
    
          # Content
          it { should set_the_flash[:notice].to(/failed/) }
          it { should render_template(:edit) }

          #Behavior
          it "should not update employee" do
            employee.reload
            employee.email.should_not eq("notcredda@email.com")
          end
        end

        context "with valid attributes (name)" do
          let(:other_employee) { FactoryGirl.create(:employee) }
          let(:attributes) { { :first_name => "Billy" } }

          before(:each) do
            do_put_update(other_employee.id, attributes)
          end
  
          # Variables
          it "has current employee" do
            subject.current_employee.should_not be_nil
          end

          # Response
          it { should assign_to(:employee) }
          it { should respond_with(:redirect) }
          it { should redirect_to(employee_employee_path(other_employee)) }
    
          # Content
          it { should set_the_flash[:notice].to(/Successfully updated/) }
          
          #Behavior
          it "should update employee" do
            other_employee.reload
            other_employee.first_name.should eq("Billy")
          end
        end

        context "with valid attributes (email)" do
          let(:other_employee) { FactoryGirl.create(:employee) }
          let(:attributes) { { :email => "new@credda.com", :email_confirmation => "new@credda.com" } }

          before(:each) do
            do_put_update(other_employee.id, attributes)
          end
  
          # Variables
          it "has current employee" do
            subject.current_employee.should_not be_nil
          end

          # Response
          it { should assign_to(:employee) }
          it { should respond_with(:redirect) }
          it { should redirect_to(employee_employee_path(other_employee)) }
    
          # Content
          it { should set_the_flash[:notice].to(/Successfully updated/) }
          
          #Behavior
          it "should update employee unconfirmed email" do
            other_employee.reload
            other_employee.unconfirmed_email.should eq("new@credda.com")
          end

          it "should send confirmation email" do
            confirmation_email_sent_to?(attributes[:email]).should be_true
          end
        end
      end
    end

    context "as authenticated customer" do
      include_context "with authenticated customer"
      let(:employee) { FactoryGirl.create(:employee) }
      let(:attributes) { { :first_name => "Billy" } }

      before(:each) do
        do_put_update(employee.id, attributes)
      end

      # Variables
      it "has current customer" do
        subject.current_customer.should_not be_nil
      end

      # Response
      it { should_not assign_to(:employee) }
      it { should respond_with(:redirect) }
      it { should redirect_to(new_employee_session_path) }

      # Content
      it { should set_the_flash[:alert].to(/need to sign in or sign up/) }
    end

    context "as authenticated store" do
      include_context "with authenticated store"
      let(:employee) { FactoryGirl.create(:employee) }
      let(:attributes) { { :first_name => "Billy" } }

      before(:each) do
        do_put_update(employee.id, attributes)
      end

      # Variables
      it "has current store" do
        subject.current_store.should_not be_nil
      end

      # Response
      it { should_not assign_to(:employee) }
      it { should respond_with(:redirect) }
      it { should redirect_to(new_employee_session_path) }

      # Content
      it { should set_the_flash[:alert].to(/need to sign in or sign up/) }
    end
  end

  describe "#destroy", :destroy => true do
    context "as unauthenticated employee" do
      include_context "with unauthenticated employee"
      let(:other_employee) { FactoryGirl.create(:employee) }

      before(:each) do
        do_delete_destroy(other_employee.id)
      end

      # Variables
      it "does not have current user" do
        subject.current_user.should be_nil
      end

      # Response
      it { should_not assign_to(:employee) }
      it { should respond_with(:redirect) }
      it { should redirect_to(new_employee_session_path) }

      # Content
      it { should set_the_flash[:alert].to(/need to sign in or sign up/) }

      # Behavior
      it "should persist Employee" do
        expect { other_employee.reload }.to_not raise_error
      end

      it "should not be cancelled" do
        other_employee.cancelled?.should be_false
      end
    end
    
    context "as authenticated employee" do
      include_context "with authenticated employee"

      context "with employee's own record" do
        before(:each) do
          do_delete_destroy(employee.id)
        end

        # Variables
        it "has current_employee" do
          subject.current_employee.should_not be_nil
        end

        # Response
        it { should assign_to(:employee) }
        it { should respond_with(:redirect) }
        it { should redirect_to(employee_employees_path) }
  
        # Content
        it { should set_the_flash[:notice].to(/Successfully cancelled/) }

        # Behavior
        it "should persist Employee" do
          expect { employee.reload }.to_not raise_error
        end

        it "should be cancelled" do
          employee.reload
          employee.cancelled?.should be_true
        end
      end

      describe "with other employee's record" do
        let(:other_employee) { FactoryGirl.create(:employee) }
        before(:each) do
          do_delete_destroy(other_employee.id)
        end

        # Variables
        it "has current employee" do
          subject.current_employee.should_not be_nil
        end

        # Response
        it { should assign_to(:employee) }
        it { should respond_with(:redirect) }
        it { should redirect_to(employee_employees_path) }
  
        # Content
        it { should set_the_flash[:notice].to(/Successfully cancelled/) }

        # Behavior
        it "should persist Employee" do
          expect { other_employee.reload }.to_not raise_error
        end

        it "should be cancelled" do
          other_employee.reload
          other_employee.cancelled?.should be_true
        end
      end
    end

    context "as authenticated customer" do
      include_context "with authenticated customer"
      let(:employee) { FactoryGirl.create(:employee) }

      before(:each) do
        do_delete_destroy(employee.id)
      end

      # Variables
      it "has current customer" do
        subject.current_customer.should_not be_nil
      end

      # Response
      it { should_not assign_to(:employee) }
      it { should respond_with(:redirect) }
      it { should redirect_to(new_employee_session_path) }

      # Content
      it { should set_the_flash[:alert].to(/need to sign in or sign up/) }

      # Behavior
      it "should persist Employee" do
        expect { employee.reload }.to_not raise_error
      end

      it "should be cancelled" do
        employee.reload
        employee.cancelled?.should be_false
      end
    end

    context "as authenticated store" do
      include_context "with authenticated store"
      let(:employee) { FactoryGirl.create(:employee) }

      before(:each) do
        do_delete_destroy(employee.id)
      end

      # Variables
      it "has current store" do
        subject.current_store.should_not be_nil
      end

      # Response
      it { should_not assign_to(:employee) }
      it { should respond_with(:redirect) }
      it { should redirect_to(new_employee_session_path) }

      # Content
      it { should set_the_flash[:alert].to(/need to sign in or sign up/) }

      # Behavior
      it "should persist Employee" do
        expect { employee.reload }.to_not raise_error
      end

      it "should be cancelled" do
        employee.reload
        employee.cancelled?.should be_false
      end
    end
  end
end