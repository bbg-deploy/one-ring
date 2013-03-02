require 'spec_helper'

describe "sign up" do
  # Feature Shared Methods
  #----------------------------------------------------------------------------
  def fill_in_customer_information(customer)
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
    choose 'customer_phone_number_attributes_cell_phone_1'
    # Terms & Conditions
    check 'customer[terms_agreement]'
  end

  # As Anonymous
  #----------------------------------------------------------------------------
  context "anonymous", :anonymous => true do
    include_context "as anonymous"
    let(:registered_customer) { FactoryGirl.create(:customer) }
    let(:customer) { FactoryGirl.build(:customer) }
    before(:each) do
      visit new_customer_registration_path
    end

    describe "valid registration" do
      context "with successful Authorize.net response" do
        before(:each) do
          webmock_authorize_net_all_successful    
        end
        
        it "creates new customer" do
          Customer.observers.enable :customer_observer do
            within("#new-registration") do
              fill_in_customer_information(customer)
              click_button 'Sign up'
            end
            
            page.should have_css("#flash-messages")
            message = YAML.load_file("#{Rails.root}/config/locales/devise.en.yml")['en']['devise']['registrations']['signed_up_but_unconfirmed']
            page.should have_content(message)
            current_path.should eq(home_path)
            
            last_email.to.should eq(["admin@credda.com"])
            a_request(:get, /http:\/\/maps.googleapis.com\/maps\/api\/geocode\/json?.*/).should have_been_made.times(2)
            a_request(:post, /https:\/\/apitest.authorize.net\/xml\/v1\/request.api.*/).with(:body => /.*createCustomerProfileRequest.*/).should have_been_made
          end
        end
      end

      context "with unsuccessful Authorize.net response" do
        before(:each) do
          webmock_authorize_net("createCustomerProfileRequest", :E00001)
        end
        
        it "does not create new customer", :failing => true do
          Customer.observers.enable :customer_observer do
            within("#new-registration") do
              fill_in_customer_information(customer)
              click_button 'Sign up'
            end
            
            page.should have_css("#flash-messages")
            message = "We had a problem processing your data"
            page.should have_content(message)
            current_path.should eq(new_customer_registration_path)
            
            last_email.to.should eq(["admin@credda.com"])
            last_email.body.should match(/Error Trace:/)
            a_request(:post, /https:\/\/apitest.authorize.net\/xml\/v1\/request.api.*/).with(:body => /.*createCustomerProfileRequest.*/).should have_been_made
          end
        end
      end
    end

    describe "invalid registration (taken username)" do
      it "creates new customer" do
        within("#new-registration") do
          fill_in_customer_information(customer)
          # Account Information
          fill_in 'customer_username', :with => registered_customer.username
          click_button 'Sign up'
        end
        
        page.should have_css("#flash-messages")
        message = "Usernamehas already been taken"
        page.should have_content(message)
        current_path.should eq(customer_registration_path)
      end      
    end

    describe "invalid registration (taken email)" do
      it "creates new customer" do
        within("#new-registration") do
          fill_in_customer_information(customer)
          fill_in 'customer_email', :with => registered_customer.email
          fill_in 'customer_email_confirmation', :with => registered_customer.email
          click_button 'Sign up'
        end
        
        page.should have_css("#flash-messages")
        message = "Emailhas already been taken"
        page.should have_content(message)
        current_path.should eq(customer_registration_path)
      end      
    end
  end

  # As Customer
  #----------------------------------------------------------------------------
  context "as customer", :authenticated => true do
    include_context "as customer"

    it "redirects to customer home" do
      visit new_customer_registration_path
      current_path.should eq(customer_home_path)
    end
  end
end