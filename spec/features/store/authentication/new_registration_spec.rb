require 'spec_helper'

describe "new registration" do
  # Feature Shared Methods
  #----------------------------------------------------------------------------
  def fill_in_store_information(store)
    # Account Information
    fill_in 'store_username', :with => store.username
    fill_in 'store_email', :with => store.email
    fill_in 'store_email_confirmation', :with => store.email
    fill_in 'store_password', :with => store.password
    fill_in 'store_password_confirmation', :with => store.password
    # Personal Information
    fill_in 'store_name', :with => store.name
    fill_in 'store_employer_identification_number', :with => store.employer_identification_number
    # Mailing Address
    fill_in 'store_addresses_attributes_0_street', :with => store.addresses.first.street
    fill_in 'store_addresses_attributes_0_city', :with => store.addresses.first.city
    select(store.addresses.first.state, :from => 'store_addresses_attributes_0_state')
    fill_in 'store_addresses_attributes_0_zip_code', :with => store.addresses.first.zip_code
    # Phone Number
    fill_in 'store_phone_numbers_attributes_0_phone_number', :with => store.phone_numbers.first.phone_number
    choose 'store_phone_numbers_attributes_0_cell_phone_1'
    # Terms & Conditions
    check 'store[terms_agreement]'
  end

  # As Anonymous
  #----------------------------------------------------------------------------
  context "as anonymous", :anonymous => true do
    include_context "as anonymous"
    let(:store) { FactoryGirl.build(:store) }
    before(:each) do
      visit new_store_registration_path      
    end

    context "with valid attributes", :failing => true do
      Store.observers.enable :store_observer do
        it "creates new store" do
          within("#new-registration") do
            fill_in_store_information(store)
            click_button 'Sign up'
          end
          
          # Page
          flash_set(:notice, :devise, :needs_confirmation)
          current_path.should eq(home_path)
          
          # Object
          Store.find_by_username(store.username).should_not be_nil
          
          # External Behavior
          confirmation_email_sent_to(store.email, store.confirmation_token)
          admin_email_alert
        end
      end
    end

    context "with invalid attributes (taken username)" do
      it "creates new store" do
        within("#new-registration") do
          fill_in_store_information(store)
          # Account Information
          fill_in 'store_username', :with => registered_store.username
          click_button 'Sign up'
        end
        
        #Page
        flash_set(:alert, :devise, :invalid_data)
        has_error(:custom, :taken)
        current_path.should eq(store_registration_path)

        #Object
        Store.find_by_username(store.username).should be_nil
                
        # External Behavior
        no_email_sent
      end      
    end

    context "with invalid registration (taken email)" do
      it "creates new store" do
        within("#new-registration") do
          fill_in_store_information(store)
          fill_in 'store_email', :with => registered_store.email
          fill_in 'store_email_confirmation', :with => registered_store.email
          click_button 'Sign up'
        end
        
        #Page
        flash_set(:alert, :devise, :invalid_data)
        has_error(:custom, :taken)
        current_path.should eq(store_registration_path)

        #Object
        Store.find_by_username(store.username).should be_nil
        
        # External Behavior
        no_email_sent
        no_authorize_net_request
      end      
    end
  end

  # As Customer
  #----------------------------------------------------------------------------
  context "as authenticated customer", :customer => true do
    include_context "as authenticated customer"
    before(:each) do
      visit new_customer_registration_path
    end

    it "redirects to customer home" do
      current_path.should eq(customer_home_path)
    end
  end

  # As Customer
  #----------------------------------------------------------------------------
  context "as authenticated customer" do
    include_context "as authenticated customer"
    before(:each) do
      visit new_store_registration_path
    end

    it "redirects to store scope conflict" do
      current_path.should eq(store_scope_conflict_path)
    end
  end

  # As Employee
  #----------------------------------------------------------------------------
  context "as authenticated employee" do
    include_context "as authenticated employee"
    before(:each) do
      visit new_store_registration_path
    end

    it "redirects to store scope conflict" do
      current_path.should eq(store_scope_conflict_path)
    end
  end
end