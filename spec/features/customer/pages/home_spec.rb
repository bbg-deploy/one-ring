require 'spec_helper'

describe "home page" do
  context "as anonymous", :anonymous => true do
    include_context "as anonymous"

    it "redirects to home" do
      visit customer_home_path
      current_path.should eq(new_customer_session_path)
    end
  end
    
  context "as customer" do
    include_context "as customer"

    it "stays on page" do
      visit customer_home_path
      current_path.should eq(customer_home_path)
    end
  end
end