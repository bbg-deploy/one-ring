module ControllerSharedContexts
  # Customer
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

  # Store
  #----------------------------------------------------------------------------  
  shared_context "with unauthenticated store" do
    let(:store) do
      store = FactoryGirl.create(:store)
      store.approve_account!
      store.confirm!
      reset_email
      store.reload
    end
  end

  shared_context "with unapproved store" do
    let(:store) do
      store = FactoryGirl.create(:store)
      reset_email
      store.reload
    end
  end

  shared_context "with unconfirmed store" do
    let(:store) do
      store = FactoryGirl.create(:store)
      store.approve_account!
      reset_email
      store.reload
    end
  end

  shared_context "with locked store" do
    let(:store) do
      store = FactoryGirl.create(:store)
      store.approve_account!
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
      store.approve_account!
      store.confirm!
      store.cancel_account!
      reset_email
      store.reload
    end
  end

  shared_context "with authenticated store" do
    let(:store) do
      store = FactoryGirl.create(:store)
      store.approve_account!
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
end