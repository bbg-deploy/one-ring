require 'spec_helper'

describe "sign up" do
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
  context "anonymous", :anonymous => true do
    include_context "as anonymous"
    let(:registered_store) { FactoryGirl.create(:store) }
    let(:store) { FactoryGirl.build(:store) }
    before(:each) do
      visit new_store_registration_path
    end

    describe "valid registration" do
      it "creates new customer" do
        within("#new-registration") do
          fill_in_store_information(store)
          click_button 'Sign up'
        end
        
        page.should have_css("#flash-messages")
        message = YAML.load_file("#{Rails.root}/config/locales/devise.en.yml")['en']['devise']['registrations']['signed_up_but_unconfirmed']
        page.should have_content(message)
        current_path.should eq(home_path)
        
        #TODO: More rigorous testing of what's happening.  Abstract into methods.
        last_email.to.should eq([store.email])
      end
    end

    describe "invalid registration (taken username)" do
      it "does not create new store" do
        within("#new-registration") do
          fill_in_store_information(store)
          # Account Information
          fill_in 'store_username', :with => registered_store.username
          click_button 'Sign up'
        end
        
        page.should have_css("#flash-messages")
        message = "Usernamehas already been taken"
        page.should have_content(message)
        current_path.should eq(store_registration_path)
      end      
    end

    describe "invalid registration (taken email)" do
      it "does not create new store" do
        within("#new-registration") do
          fill_in_store_information(store)
          fill_in 'store_email', :with => registered_store.email
          fill_in 'store_email_confirmation', :with => registered_store.email
          click_button 'Sign up'
        end
        
        page.should have_css("#flash-messages")
        message = "Emailhas already been taken"
        page.should have_content(message)
        current_path.should eq(store_registration_path)
      end
    end
  end

  # As Customer
  #----------------------------------------------------------------------------
  context "as store", :authenticated => true do
    include_context "as store"

    it "redirects to store home" do
      visit new_store_registration_path
      current_path.should eq(store_home_path)
    end
  end
end