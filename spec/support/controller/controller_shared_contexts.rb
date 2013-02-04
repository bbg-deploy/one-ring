module ControllerSharedContexts
  shared_context "as anonymous" do
    let(:user) { nil }
    before(:each) { @request.env["devise.mapping"] = Devise.mappings[:user] }
  end

  shared_context "as admin" do
    let(:admin) { FactoryGirl.create(:admin) }
    before(:each) { confirm_and_login(admin) }
  end

  shared_context "as analyst" do
    let(:analyst) { FactoryGirl.create(:analyst) }
    before(:each) { confirm_and_login(analyst) }
  end

  shared_context "as agent" do
    let(:agent) { FactoryGirl.create(:agent) }
    before(:each) { confirm_and_login(agent) }
  end

  shared_context "as store" do
    let(:store) { FactoryGirl.create(:store) }
    before(:each) { confirm_and_login(store) }
  end

  shared_context "as customer" do
    let(:customer) { FactoryGirl.create(:customer) }
    before(:each) { confirm_and_login(customer) }
  end
end