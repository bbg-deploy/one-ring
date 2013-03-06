require 'spec_helper'

describe "home page" do
  # As Anonymous
  #----------------------------------------------------------------------------
  context "as anonymous", :anonymous => true do
    include_context "as anonymous"
    before(:each) do
      visit customer_home_path
    end

    it "redirects to customer sign-in" do
      current_path.should eq(new_customer_session_path)
    end
  end
    
  # As Authenticated Customer
  #----------------------------------------------------------------------------
  context "as authenticated customer" do
    include_context "as authenticated customer"
    before(:each) do
      visit customer_home_path
    end

    it "stays on page" do
      current_path.should eq(customer_home_path)
    end
  end
  # As Store
  #----------------------------------------------------------------------------
  context "as authenticated store" do
    include_context "as authenticated store"
    before(:each) do
      visit new_customer_unlock_path
    end

    it "redirects to customer home" do
      current_path.should eq(customer_scope_conflict_path)
    end
  end

  # As Employee
  #----------------------------------------------------------------------------
  context "as authenticated employee" do
    include_context "as authenticated employee"
    before(:each) do
      visit new_customer_unlock_path
    end

    it "redirects to customer home" do
      current_path.should eq(customer_scope_conflict_path)
    end
  end
end