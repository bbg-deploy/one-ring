module ControllerSharedContexts
  # Customer Contexts
  #----------------------------------------------------------------------------  
  shared_context "as unauthenticated, unconfirmed customer" do
    let(:customer) do
      customer = FactoryGirl.create(:customer)
      reset_email
      customer.reload
    end

    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:customer]
    end
  end

  shared_context "as unauthenticated customer" do
    let(:customer) do
      customer = FactoryGirl.create(:customer)
      customer.confirm!
      reset_email
      customer.reload
    end

    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:customer]
    end
  end

  shared_context "as unauthenticated, locked customer" do
    let(:customer) do
      customer = FactoryGirl.create(:customer)
      customer.confirm!
      customer.lock_access!
      reset_email
      customer.reload
    end

    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:customer]
    end
  end

  shared_context "as unauthenticated customer with password reset request" do
    let(:customer) do
      customer = FactoryGirl.create(:customer)
      customer.confirm!
      customer.send_reset_password_instructions
      reset_email
      customer.reload
    end

    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:customer]
    end
  end

  shared_context "as unauthenticated, unconfirmed customer with password reset request" do
    let(:customer) do
      customer = FactoryGirl.create(:customer)
      customer.send_reset_password_instructions
      reset_email
      customer.reload
    end

    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:customer]
    end
  end

  shared_context "as authenticated customer" do
    let(:customer) do
      customer = FactoryGirl.create(:customer)
      customer.confirm!
      reset_email
      customer.reload
    end

    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:customer]
      sign_in customer
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
end