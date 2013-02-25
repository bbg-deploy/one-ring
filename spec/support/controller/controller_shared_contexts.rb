module ControllerSharedContexts
  # New Customer Contexts
  #----------------------------------------------------------------------------  
  shared_context "with unauthenticated customer" do
    let(:customer) do
      customer = FactoryGirl.create(:customer)
      customer.confirm!
      reset_email
      customer.reload
    end
  end

  shared_context "with unconfirmed customer" do
    let(:customer) do
      customer = FactoryGirl.create(:customer)
      reset_email
      customer.reload
    end
  end

  shared_context "with locked customer" do
    let(:customer) do
      customer = FactoryGirl.create(:customer)
      customer.confirm!
      customer.failed_attempts = 6
      customer.lock_access!
      reset_email
      customer.reload
    end
  end

  shared_context "with cancelled customer" do
    let(:customer) do
      customer = FactoryGirl.create(:customer)
      customer.confirm!
      customer.cancel_account!
      reset_email
      customer.reload
    end
  end

  shared_context "with authenticated customer" do
    let(:customer) do
      customer = FactoryGirl.create(:customer)
      customer.confirm!
      reset_email
      customer.reload
    end

    before(:each) do
      sign_in :customer, customer
    end
  end

  # New Store Contexts
  #----------------------------------------------------------------------------  
  shared_context "with unauthenticated store" do
    let(:store) do
      store = FactoryGirl.create(:store)
      store.confirm!
      reset_email
      store.reload
    end
  end

  shared_context "with unconfirmed store" do
    let(:store) do
      store = FactoryGirl.create(:store)
      reset_email
      store.reload
    end
  end

  shared_context "with locked store" do
    let(:store) do
      store = FactoryGirl.create(:store)
      store.confirm!
      store.failed_attempts = 6
      store.lock_access!
      reset_email
      store.reload
    end
  end

  shared_context "with cancelled store" do
    let(:store) do
      store = FactoryGirl.create(:store)
      store.confirm!
      store.cancel_account!
      reset_email
      store.reload
    end
  end

  shared_context "with authenticated store" do
    let(:store) do
      store = FactoryGirl.create(:store)
      store.confirm!
      reset_email
      store.reload
    end

    before(:each) do
      sign_in :store, store
    end
  end

  # New Employee Contexts
  #----------------------------------------------------------------------------  
  shared_context "with unauthenticated employee" do
    let(:employee) do
      employee = FactoryGirl.create(:employee)
      employee.confirm!
      reset_email
      employee.reload
    end
  end

  shared_context "with unconfirmed employee" do
    let(:employee) do
      employee = FactoryGirl.create(:employee)
      reset_email
      employee.reload
    end
  end

  shared_context "with locked employee" do
    let(:employee) do
      employee = FactoryGirl.create(:employee)
      employee.confirm!
      employee.failed_attempts = 6
      employee.lock_access!
      reset_email
      employee.reload
    end
  end

  shared_context "with cancelled employee" do
    let(:employee) do
      employee = FactoryGirl.create(:employee)
      employee.confirm!
      employee.cancel_account!
      reset_email
      employee.reload
    end
  end

  shared_context "with authenticated employee" do
    let(:employee) do
      employee = FactoryGirl.create(:employee)
      employee.confirm!
      reset_email
      employee.reload
    end

    before(:each) do
      sign_in :employee, employee
    end
  end

  # Store Contexts
  #----------------------------------------------------------------------------  
  shared_context "as unauthenticated, unconfirmed store" do
    let(:store) do
      store = FactoryGirl.create(:store)
      reset_email
      store.reload
    end

    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:store]
    end
  end

  shared_context "as unauthenticated store" do
    let(:store) do
      store = FactoryGirl.create(:store)
      store.confirm!
      reset_email
      store.reload
    end

    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:store]
    end
  end

  shared_context "as unauthenticated, locked store" do
    let(:store) do
      store = FactoryGirl.create(:store)
      store.confirm!
      store.lock_access!
      reset_email
      store.reload
    end

    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:store]
    end
  end

  shared_context "as unauthenticated store with password reset request" do
    let(:store) do
      store = FactoryGirl.create(:store)
      store.confirm!
      store.send_reset_password_instructions
      reset_email
      store.reload
    end

    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:store]
    end
  end

  shared_context "as unauthenticated, unconfirmed store with password reset request" do
    let(:store) do
      store = FactoryGirl.create(:store)
      store.send_reset_password_instructions
      reset_email
      store.reload
    end

    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:store]
    end
  end

  shared_context "as authenticated store" do
    let(:store) do
      store = FactoryGirl.create(:store)
      store.confirm!
      reset_email
      store.reload
    end

    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:store]
      sign_in store
    end
  end

  # Employee Contexts
  #----------------------------------------------------------------------------  
  shared_context "as unauthenticated, unconfirmed employee" do
    let(:employee) do
      employee = FactoryGirl.create(:employee)
      reset_email
      employee.reload
    end

    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:employee]
    end
  end

  shared_context "as unauthenticated employee" do
    let(:employee) do
      employee = FactoryGirl.create(:employee)
      employee.confirm!
      reset_email
      employee.reload
    end

    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:employee]
    end
  end

  shared_context "as unauthenticated, locked employee" do
    let(:employee) do
      employee = FactoryGirl.create(:employee)
      employee.confirm!
      employee.lock_access!
      reset_email
      employee.reload
    end

    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:employee]
    end
  end

  shared_context "as unauthenticated employee with password reset request" do
    let(:employee) do
      employee = FactoryGirl.create(:employee)
      employee.confirm!
      employee.send_reset_password_instructions
      reset_email
      employee.reload
    end

    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:employee]
    end
  end

  shared_context "as unauthenticated, unconfirmed employee with password reset request" do
    let(:employee) do
      employee = FactoryGirl.create(:employee)
      employee.send_reset_password_instructions
      reset_email
      employee.reload
    end

    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:employee]
    end
  end

  shared_context "as authenticated employee" do
    let(:employee) do
      employee = FactoryGirl.create(:employee)
      employee.confirm!
      reset_email
      employee.reload
    end

    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:employee]
      sign_in employee
    end
  end
end