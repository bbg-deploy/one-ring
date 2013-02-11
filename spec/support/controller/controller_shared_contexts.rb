module ControllerSharedContexts
  shared_context "as unauthenticated, unconfirmed customer" do
    let(:customer) do
      customer = FactoryGirl.create(:customer)
      reset_email
      customer.reload
    end

    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:customer]
      reset_email
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
end