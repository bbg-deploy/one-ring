require 'spec_helper'

describe "new registration" do
  let!(:registered_customer) { FactoryGirl.create(:customer) }
  before(:each) do
    WebMock.reset!
    webmock_geocoder
    reset_email
  end

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
    let(:customer) { FactoryGirl.build(:customer) }
    before(:each) do
      visit new_customer_registration_path      
    end

    describe "valid registration", :failing => true do
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
            
            # Page
            flash_set(:notice, :devise, :needs_confirmation)
            current_path.should eq(home_path)
            
            # Object
            Customer.find_by_username(customer.username).should_not be_nil
            
            # External Behavior
            confirmation_email_sent_to(customer.email, customer.confirmation_token)
            admin_email_alert
            made_authorize_net_request("createCustomerProfileRequest")
            made_google_api_request
          end
        end
      end

      context "with unsuccessful Authorize.net response" do
        before(:each) do
          webmock_authorize_net("createCustomerProfileRequest", :E00001)
        end
        
        it "does not create new customer" do
          Customer.observers.enable :customer_observer do
            within("#new-registration") do
              fill_in_customer_information(customer)
              click_button 'Sign up'
            end
            
            # Page
            flash_set(:alert, :devise, :authorize_net_error)
            current_path.should eq(new_customer_registration_path)
            
            # Object
            Customer.find_by_username(customer.username).should be_nil

            # External Behavior
            admin_email_alert
            made_authorize_net_request("createCustomerProfileRequest")
            made_google_api_request
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
        
        #Page
        flash_set(:alert, :devise, :invalid_data)
        page.should have_content("Usernamehas already been taken")
        current_path.should eq(customer_registration_path)

        #Object
        Customer.find_by_username(customer.username).should be_nil
        
        # External Behavior
        no_email_sent
        no_authorize_net_request
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
        
        #Page
        flash_set(:alert, :devise, :invalid_data)
        page.should have_content("Emailhas already been taken")
        current_path.should eq(customer_registration_path)

        #Object
        Customer.find_by_username(customer.username).should be_nil
        
        # External Behavior
        no_email_sent
        no_authorize_net_request
      end      
    end
  end

  # As Customer
  #----------------------------------------------------------------------------
  context "as customer", :customer => true do
    include_context "as customer"
    before(:each) do
      visit new_customer_registration_path
    end

    it "redirects to customer home" do
      current_path.should eq(customer_home_path)
    end
  end

  # As Store
  #----------------------------------------------------------------------------
  context "as store", :store => true do
    include_context "as store"
    before(:each) do
      visit new_customer_registration_path
    end

    it "redirects to customer scope conflict" do
      current_path.should eq(customer_scope_conflict_path)
    end
  end

  # As Employee
  #----------------------------------------------------------------------------
  context "as employee", :employee => true do
    include_context "as employee"
    before(:each) do
      visit new_customer_registration_path
    end

    it "redirects to customer scope conflict" do
      current_path.should eq(customer_scope_conflict_path)
    end
  end
end