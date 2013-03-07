require 'spec_helper'

describe "#new" do
  context "as anonymous", :anonymous => true do
    include_context "as anonymous"

    it "redirects to home" do
      visit new_customer_payment_profile_path
      current_path.should eq(new_customer_session_path)
    end
  end
  
  context "as authenticated customer", :authenticated => true do
    include_context "as authenticated customer"
    before(:each) do
      visit new_customer_payment_profile_path
    end

    it "does not redirect" do
      current_path.should eq(new_customer_payment_profile_path)
    end

    context "new credit card" do
      before(:each) do
        page.click_on("creditCard")        
      end      
      describe "with valid attributes" do
        it "creates payment profile" do  
          within("#creditCardTab") do
            # Personal Info
            fill_in 'payment_profile_first_name', :with => customer.first_name
            fill_in 'payment_profile_last_name', :with => customer.last_name
            # Credit Card Info
            select('visa', :from => 'payment_profile_credit_card_attributes_brand')
            fill_in 'payment_profile_credit_card_attributes_credit_card_number', :with => "4111111111111111"
            select('October', :from => 'payment_profile_credit_card_attributes_expiration_date_2i')
            select('2014', :from => 'payment_profile_credit_card_attributes_expiration_date_1i')
            fill_in 'payment_profile_credit_card_attributes_ccv_number', :with => "515"
            # Billing Address Info
            fill_in 'payment_profile_billing_address_attributes_street', :with => customer.mailing_address.street
            fill_in 'payment_profile_billing_address_attributes_city', :with => customer.mailing_address.city
            select(customer.mailing_address.state, :from => 'payment_profile_billing_address_attributes_state')
            fill_in 'payment_profile_billing_address_attributes_zip_code', :with => customer.mailing_address.zip_code
            select(customer.mailing_address.country, :from => 'payment_profile_billing_address_attributes_country')
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
        page.click_on("bankAccount")        
      end      
      describe "with valid attributes" do
        it "creates payment profile" do  
          within("#bankAccountTab") do
            # Personal Info
            fill_in 'payment_profile_first_name', :with => customer.first_name
            fill_in 'payment_profile_last_name', :with => customer.last_name
            # Bank Account Info
            select('personal', :from => 'payment_profile_bank_account_attributes_account_holder')
            select('checking', :from => 'payment_profile_bank_account_attributes_account_type')
            fill_in 'payment_profile_bank_account_attributes_account_number', :with => "123456789012"
            fill_in 'payment_profile_bank_account_attributes_routing_number', :with => "111000025"
            # Billing Address Info
            fill_in 'payment_profile_billing_address_attributes_street', :with => customer.mailing_address.street
            fill_in 'payment_profile_billing_address_attributes_city', :with => customer.mailing_address.city
            select(customer.mailing_address.state, :from => 'payment_profile_billing_address_attributes_state')
            fill_in 'payment_profile_billing_address_attributes_zip_code', :with => customer.mailing_address.zip_code
            select(customer.mailing_address.country, :from => 'payment_profile_billing_address_attributes_country')
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