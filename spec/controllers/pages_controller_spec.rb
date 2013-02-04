require 'spec_helper'

describe PagesController do  
  context "as anonymous user" do
    include_context "as anonymous"
    
    specify { subject.current_admin.should be_nil }
    specify { subject.current_agent.should be_nil }
    specify { subject.current_analyst.should be_nil }
    specify { subject.current_store.should be_nil }
    specify { subject.current_customer.should be_nil }
    it "render home template" do
      get :home
      response.should render_template '/home'
    end
  end

  context "as admin" do
    include_context "as admin"

    specify { subject.current_admin.should_not be_nil }
    specify { subject.current_agent.should be_nil }
    specify { subject.current_analyst.should be_nil }
    specify { subject.current_store.should be_nil }
    specify { subject.current_customer.should be_nil }
    it "redirects to admin home" do
      get :home
      response.should redirect_to [:admin, :home]
    end
  end

  context "as analyst" do
    include_context "as analyst"

    specify { subject.current_admin.should be_nil }
    specify { subject.current_agent.should be_nil }
    specify { subject.current_analyst.should_not be_nil }
    specify { subject.current_store.should be_nil }
    specify { subject.current_customer.should be_nil }
    it "redirects to agent home" do
      get :home
      response.should redirect_to [:analyst, :home]
    end
  end

  context "as agent" do
    include_context "as agent"

    specify { subject.current_admin.should be_nil }
    specify { subject.current_agent.should_not be_nil }
    specify { subject.current_analyst.should be_nil }
    specify { subject.current_store.should be_nil }
    specify { subject.current_customer.should be_nil }
    it "redirects to agent home" do
      get :home
      response.should redirect_to [:agent, :home]
    end
  end
    
  context "as store" do
    include_context "as store"

    specify { subject.current_admin.should be_nil }
    specify { subject.current_agent.should be_nil }
    specify { subject.current_store.should_not be_nil }
    specify { subject.current_customer.should be_nil }
    it "redirects to store home" do
      get :home
      response.should redirect_to [:store, :home]
    end
  end

  context "as customer" do
    include_context "as customer"

    specify { subject.current_admin.should be_nil }
    specify { subject.current_agent.should be_nil }
    specify { subject.current_store.should be_nil }
    specify { subject.current_customer.should_not be_nil }
    it "redirects to customer home" do
      get :home
      response.should redirect_to [:customer, :home]
    end
  end
end