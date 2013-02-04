require 'spec_helper'

describe "edit_account" do
  context "anonymous", :anonymous => true do
    include_context "as anonymous visitor"
    before(:each) do
      visit edit_customer_registration_path
    end

    it "redirects to customer home" do
      current_path.should eq(customer_home_path)
    end
  end

  context "authenticated", :authenticated => true do
    include_context "as authenticated customer"
    before(:each) do
      visit edit_customer_registration_path
    end

    describe "with all fields valid" do
      it "edits customer information" do
        within("#edit_customer_#{customer.id}") do
          fill_in 'customer_username', :with => customer.username
          fill_in 'customer_password', :with => customer.password
#          fill_in 'customer_current_password', :with => customer.password
          fill_in 'customer_password_confirmation', :with => customer.password
          fill_in 'customer_email', :with => customer.email
          fill_in 'customer_email_confirmation', :with => customer.email
          fill_in 'customer_first_name', :with => customer.first_name
          fill_in 'customer_middle_name', :with => customer.middle_name
          fill_in 'customer_last_name', :with => customer.last_name
          select('1980', :from => 'customer_date_of_birth_1i')
          select('June', :from => 'customer_date_of_birth_2i')
          select('15', :from => 'customer_date_of_birth_3i')
          fill_in 'customer_social_security_number', :with => customer.social_security_number
          # Billing Address
          fill_in 'customer_billing_addresses_attributes_0_street', :with => customer.billing_addresses.first.street
          fill_in 'customer_billing_addresses_attributes_0_city', :with => customer.billing_addresses.first.city
          select(customer.billing_addresses.first.state, :from => 'customer_billing_addresses_attributes_0_state')
          fill_in 'customer_billing_addresses_attributes_0_zip_code', :with => customer.billing_addresses.first.zip_code
          #TODO: Uncomment these if we ever separate mailing addresses & billing addresses
          # Mailing Address
          fill_in 'customer_mailing_addresses_attributes_0_street', :with => customer.mailing_addresses.first.street
          fill_in 'customer_mailing_addresses_attributes_0_city', :with => customer.mailing_addresses.first.city
          select(customer.mailing_addresses.first.state, :from => 'customer_mailing_addresses_attributes_0_state')
          fill_in 'customer_mailing_addresses_attributes_0_zip_code', :with => customer.mailing_addresses.first.zip_code
          # Phone Number
          fill_in 'customer_phone_numbers_attributes_0_phone_number', :with => customer.phone_numbers.first.phone_number
#          check 'customer_phone_numbers_attributes_0_primary'
          uncheck 'customer_phone_numbers_attributes_0_cell_phone'
          # Account Information
          check 'customer[terms_agreement]'

          click_button 'Sign up'
        end
        
        page.should have_css("#flash-messages")
        message = YAML.load_file("#{Rails.root}/config/locales/devise.en.yml")['en']['devise']['registrations']['signed_up_but_unconfirmed']
        page.should have_content(message)
        current_path.should eq(home_path)
      end      
    end
  end
end