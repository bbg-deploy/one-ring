module FeatureSharedContexts
  shared_context "as anonymous" do
    let(:user) { nil }
  end

  shared_context "as customer" do
    let(:customer) { FactoryGirl.create(:customer) }
    before(:each) { confirm_and_login(customer, :customer) }
  end

  shared_context "as store" do
    let(:store) { FactoryGirl.create(:store) }
    before(:each) { confirm_and_login(store, :store) }
  end

  shared_context "as employee" do
    let(:agent) { FactoryGirl.create(:employee) }
    before(:each) { confirm_and_login(agent, :employee) }
  end
end