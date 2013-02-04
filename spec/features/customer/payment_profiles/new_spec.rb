require 'spec_helper'

describe "new" do
  context "anonymous", :anonymous => true do
    include_context "as anonymous visitor"

    it "redirects to home" do
      visit new_customer_payment_profile_path
      current_path.should eq(new_customer_session_path)
    end
  end
  
  context "authenticated", :authenticated => true do
    include_context "as authenticated customer"
    before(:each) do
      visit new_customer_payment_profile_path
    end

    it "does not redirect" do
      current_path.should eq(new_customer_payment_profile_path)
    end

    context "new credit card" do
      before(:each) do
        page.click_on("credit-card-tab")        
      end      
      describe "with valid attributes", :failing => true do
        it "creates payment profile" do  
          within("#credit-card-tab-pane") do
            fill_in 'payment_profile_credit_card_first_name', :with => customer.first_name
            fill_in 'payment_profile_credit_card_last_name', :with => customer.last_name
            select('visa', :from => 'payment_profile_credit_card_brand')
            fill_in 'payment_profile_credit_card_number', :with => "4111222233331234"
            select('10', :from => 'payment_profile_credit_card_expiration_month')
            select('2014', :from => 'payment_profile_credit_card_expiration_year')
            fill_in 'payment_profile_credit_card_verification', :with => "515"
            click_button 'Save'
          end
          
          page.should have_css("#flash-messages")
          page.should have_content("Successfully created payment profile.")
          current_path.should eq(customer_payment_profile_path(PaymentProfile.last))
        end      
      end
    end

    context "new bank account" do
      before(:each) do
        page.click_on("bank-account-tab")        
      end      
      describe "with valid attributes", :failing => true do
        it "creates payment profile" do  
          within("#bank-account-tab-pane") do
            fill_in 'payment_profile_bank_account_name', :with => "#{customer.first_name} #{customer.last_name}"
            select('checking', :from => 'payment_profile_bank_account_type')
            fill_in 'payment_profile_bank_account_number', :with => "123000789"
            fill_in 'payment_profile_bank_routing_number', :with => "21234570"
            click_button 'Save'
          end
          
          page.should have_css("#flash-messages")
          page.should have_content("Successfully created payment profile.")
          current_path.should eq(customer_payment_profile_path(PaymentProfile.last))
        end      
      end
    end
  end
end