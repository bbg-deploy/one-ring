module FeatureSharedContexts
  # Anonymous
  #----------------------------------------------------------------------------
  shared_context "as anonymous" do
    let!(:registered_customer) { FactoryGirl.create(:customer) }
    let!(:registered_store) { FactoryGirl.create(:store) }
    let!(:registered_employee) { FactoryGirl.create(:employee) }
    before(:each) do
      reset_email
    end
  end

  # Customers
  #----------------------------------------------------------------------------
  shared_context "as unauthenticated customer" do
    let!(:registered_customer) { FactoryGirl.create(:customer) }
    let!(:customer) { FactoryGirl.create(:customer) }
    before(:each) do
      customer.confirm!
      reset_email
    end
  end

  shared_context "as unconfirmed customer" do
    let!(:registered_customer) { FactoryGirl.create(:customer) }
    let!(:customer) { FactoryGirl.create(:customer) }
    before(:each) do
      reset_email
    end
  end

  shared_context "as locked customer" do
    let!(:registered_customer) { FactoryGirl.create(:customer) }
    let!(:customer) { FactoryGirl.create(:customer) }
    before(:each) do
      customer.confirm!
      customer.lock_access!
      reset_email
    end
  end

  shared_context "as authenticated customer" do
    let!(:registered_customer) { FactoryGirl.create(:customer) }
    let!(:customer) { FactoryGirl.create(:customer) }
    before(:each) do
      customer.confirm!
      login_as customer, scope: :customer
      reset_email
    end
  end

  # Stores
  #----------------------------------------------------------------------------
  shared_context "as unauthenticated store" do
    let!(:registered_store) { FactoryGirl.create(:store) }
    let!(:store) { FactoryGirl.create(:store) }
    before(:each) do
      store.confirm!
      reset_email
    end
  end

  shared_context "as unconfirmed store" do
    let!(:registered_store) { FactoryGirl.create(:store) }
    let!(:store) { FactoryGirl.create(:store) }
    before(:each) do
      reset_email
    end
  end

  shared_context "as locked store" do
    let!(:registered_store) { FactoryGirl.create(:store) }
    let!(:store) { FactoryGirl.create(:store) }
    before(:each) do
      store.confirm!
      store.lock_access!
      reset_email
    end
  end

  shared_context "as authenticated store" do
    let!(:registered_store) { FactoryGirl.create(:store) }
    let!(:store) { FactoryGirl.create(:store) }
    before(:each) do
      store.confirm!
      login_as store, scope: :store
      reset_email
    end
  end

  # Employees
  #----------------------------------------------------------------------------
  shared_context "as authenticated employee" do
    let!(:registered_employee) { FactoryGirl.create(:employee) }
    let!(:employee) { FactoryGirl.create(:employee) }
    before(:each) do
      employee.approve!
      employee.confirm!
      login_as employee, scope: :employee
      reset_email
    end
  end
end