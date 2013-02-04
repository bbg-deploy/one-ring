module FeatureSharedContexts
  shared_context "as anonymous visitor" do
    let(:user) { nil }
  end

  shared_context "as authenticated customer" do
    let(:customer) { FactoryGirl.create(:customer) }
    before(:each) { confirm_and_login(customer, :customer) }
  end

  shared_context "as authenticated store" do
    let(:store) { FactoryGirl.create(:store) }
    before(:each) { confirm_and_login(store, :store) }
  end

  shared_context "as authenticated agent" do
    let(:agent) { FactoryGirl.create(:agent) }
    before(:each) { confirm_and_login(agent, :agent) }
  end

  shared_context "as authenticated admin" do
    let(:admin) { FactoryGirl.create(:admin) }
    before(:each) { confirm_and_login(admin, :admin) }
  end
end