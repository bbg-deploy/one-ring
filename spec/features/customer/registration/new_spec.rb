require 'spec_helper'

describe "sign up" do
  context "anonymous", :anonymous => true do
    include_context "as anonymous visitor"
    let(:registered_customer) { FactoryGirl.create(:customer) }
    let(:customer) { FactoryGirl.build(:customer) }
    before(:each) do
      visit new_customer_registration_path
    end

    describe "with valid attributes" do
      it "creates new customer" do
        within("#registrations-new") do
          # Account Information
          fill_in 'customer_username', :with => customer.username
          fill_in 'customer_email', :with => customer.email
          fill_in 'customer_email_confirmation', :with => customer.email
          fill_in 'customer_password', :with => customer.password
          fill_in 'customer_password_confirmation', :with => customer.password
          # Personal Information
          fill_in 'customer_first_name', :with => customer.first_name
          fill_in 'customer_middle_name', :with => customer.middle_name
          fill_in 'customer_last_name', :with => customer.last_name
          fill_in 'customer_date_of_birth', :with => customer.date_of_birth
          fill_in 'customer_social_security_number', :with => customer.social_security_number
          # Mailing Address
          fill_in 'customer_mailing_address_attributes_street', :with => customer.mailing_address.street
          fill_in 'customer_mailing_address_attributes_city', :with => customer.mailing_address.city
          select(customer.mailing_address.state, :from => 'customer_mailing_address_attributes_state')
          fill_in 'customer_mailing_address_attributes_zip_code', :with => customer.mailing_address.zip_code
          # Phone Number
          fill_in 'customer_phone_number_attributes_phone_number', :with => customer.phone_number.phone_number
          check 'customer_phone_number_attributes_cell_phone'
          # Terms & Conditions
          check 'customer[terms_agreement]'

          click_button 'Sign up'
        end
        
        page.should have_css("#flash-messages")
        message = YAML.load_file("#{Rails.root}/config/locales/devise.en.yml")['en']['devise']['registrations']['signed_up_but_unconfirmed']
        page.should have_content(message)
        current_path.should eq(home_path)
      end
    end

    describe "with taken username" do
      it "creates new customer" do
        within("#registrations-new") do
          # Account Information
          fill_in 'customer_username', :with => registered_customer.username
          fill_in 'customer_email', :with => customer.email
          fill_in 'customer_email_confirmation', :with => customer.email
          fill_in 'customer_password', :with => customer.password
          fill_in 'customer_password_confirmation', :with => customer.password
          # Personal Information
          fill_in 'customer_first_name', :with => customer.first_name
          fill_in 'customer_middle_name', :with => customer.middle_name
          fill_in 'customer_last_name', :with => customer.last_name
          fill_in 'customer_date_of_birth', :with => customer.date_of_birth
          fill_in 'customer_social_security_number', :with => customer.social_security_number
          # Mailing Address
          fill_in 'customer_mailing_address_attributes_street', :with => customer.mailing_address.street
          fill_in 'customer_mailing_address_attributes_city', :with => customer.mailing_address.city
          select(customer.mailing_address.state, :from => 'customer_mailing_address_attributes_state')
          fill_in 'customer_mailing_address_attributes_zip_code', :with => customer.mailing_address.zip_code
          # Phone Number
          fill_in 'customer_phone_number_attributes_phone_number', :with => customer.phone_number.phone_number
          check 'customer_phone_number_attributes_cell_phone'
          # Terms & Conditions
          check 'customer[terms_agreement]'

          click_button 'Sign up'
        end
        
        page.should have_css("#flash-messages")
        message = "Username has already been taken"
        page.should have_content(message)
        current_path.should eq(customer_registration_path)
      end      
    end

    describe "with taken email" do
      it "creates new customer" do
        within("#registrations-new") do
          # Account Information
          fill_in 'customer_username', :with => customer.username
          fill_in 'customer_email', :with => registered_customer.email
          fill_in 'customer_email_confirmation', :with => registered_customer.email
          fill_in 'customer_password', :with => customer.password
          fill_in 'customer_password_confirmation', :with => customer.password
          # Personal Information
          fill_in 'customer_first_name', :with => customer.first_name
          fill_in 'customer_middle_name', :with => customer.middle_name
          fill_in 'customer_last_name', :with => customer.last_name
          fill_in 'customer_date_of_birth', :with => customer.date_of_birth
          fill_in 'customer_social_security_number', :with => customer.social_security_number
          # Mailing Address
          fill_in 'customer_mailing_address_attributes_street', :with => customer.mailing_address.street
          fill_in 'customer_mailing_address_attributes_city', :with => customer.mailing_address.city
          select(customer.mailing_address.state, :from => 'customer_mailing_address_attributes_state')
          fill_in 'customer_mailing_address_attributes_zip_code', :with => customer.mailing_address.zip_code
          # Phone Number
          fill_in 'customer_phone_number_attributes_phone_number', :with => customer.phone_number.phone_number
          check 'customer_phone_number_attributes_cell_phone'
          # Terms & Conditions
          check 'customer[terms_agreement]'

          click_button 'Sign up'
        end
        
        page.should have_css("#flash-messages")
        message = "Email has already been taken"
        page.should have_content(message)
        current_path.should eq(customer_registration_path)
      end      
    end
  end

  context "authenticated", :authenticated => true do
    include_context "as authenticated customer"

    it "redirects to customer home" do
      visit new_customer_registration_path
      current_path.should eq(customer_home_path)
    end
  end
end