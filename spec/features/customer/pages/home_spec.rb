require 'spec_helper'

describe "home page" do
  context "anonymous", :anonymous => true do
    include_context "as anonymous visitor"

    it "redirects to home" do
      visit customer_home_path
      current_path.should eq(new_customer_session_path)
    end
  end
    
  context "authenticated" do
    include_context "as authenticated customer"

    context "with unclaimed contracts" do
      let(:unclaimed_contract) { FactoryGirl.create(:contract, :customer => nil, :matching_email => customer.email) }
      let(:unsubmitted_contract) { FactoryGirl.create(:contract, :customer => customer) }
      let(:unsubmitted_contract2) { FactoryGirl.create(:contract, :customer => customer) }
      before(:each) do
        unclaimed_contract.reload
        unsubmitted_contract.reload
        unsubmitted_contract2.reload
        visit customer_home_path 
      end
      
      it "lists unclaimed contracts" do
        page.should have_content("TEST")
#        page.should have_css("#unclaimed_contracts")
#        page.should_not have_css("#unsubmitted_contracts")
#        page.should_not have_css("#approved_contracts")
      end
  
      it "allows claiming of application" do
        click_button 'Yes, This Is My Contract'
        current_path.should eq(customer_contracts_path(unclaimed_contract))
      end
    end
  end
end