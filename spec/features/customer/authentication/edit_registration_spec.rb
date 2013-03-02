require 'spec_helper'

describe "edit_account" do
  # Feature Shared Methods
  #----------------------------------------------------------------------------
  def fill_in_customer_information(customer)
    # Terms & Conditions
    check 'customer[terms_agreement]'
  end

  # As Anonymous
  #----------------------------------------------------------------------------
  context "as anonymous", :anonymous => true do
    include_context "as anonymous"
    before(:each) do
      visit edit_customer_registration_path
    end

    it "redirects to customer home" do
      current_path.should eq(new_customer_session_path)
    end
  end

  # As Customer
  #----------------------------------------------------------------------------
  context "as customer", :authenticated => true do
    include_context "as customer"
    before(:each) do
      visit edit_customer_registration_path
    end
    
    describe "valid name change" do
      context "with successful Authorize.net response" do
        before(:each) do
          webmock_authorize_net_all_successful    
        end

        it "edits customer information" do
          Customer.observers.enable :customer_observer do
            within("#edit-registration") do
              fill_in 'customer_first_name', :with => "Dick"
              fill_in 'customer_last_name', :with => "Tracy"
              # Current Password
              fill_in 'customer_current_password', :with => customer.password
    
              click_button 'Save Account Changes'
            end
            
            page.should have_css("#flash-messages")
            message = YAML.load_file("#{Rails.root}/config/locales/devise.en.yml")['en']['devise']['registrations']['updated']
            page.should have_content(message)
            current_path.should eq(customer_home_path)
    
            customer.reload
            customer.first_name.should eq("Dick")
            customer.last_name.should eq("Tracy")

            a_request(:post, /https:\/\/apitest.authorize.net\/xml\/v1\/request.api.*/).with(:body => /.*updateCustomerProfileRequest.*/).should have_been_made
          end
        end
      end

      context "with unsuccessful Authorize.net response" do
        before(:each) do
          webmock_authorize_net("updateCustomerProfileRequest", :E00001)
        end

        it "does not edit customer information" do
          Customer.observers.enable :customer_observer do
            within("#edit-registration") do
              fill_in 'customer_first_name', :with => "Dick"
              fill_in 'customer_last_name', :with => "Tracy"
              # Current Password
              fill_in 'customer_current_password', :with => customer.password
    
              click_button 'Save Account Changes'
            end
            
            page.should have_css("#flash-messages")
            page.should have_content("We had a problem processing your data")
            current_path.should eq(edit_customer_registration_path)
    
            customer.reload
            customer.first_name.should_not eq("Dick")
            customer.last_name.should_not eq("Tracy")

            a_request(:post, /https:\/\/apitest.authorize.net\/xml\/v1\/request.api.*/).with(:body => /.*updateCustomerProfileRequest.*/).should have_been_made
          end
        end
      end
    end

    describe "valid email change" do
      it "edits customer information" do
        within("#edit-registration") do
          # Account information
          fill_in 'customer_email', :with => "newemail@notcredda.com"
          fill_in 'customer_email_confirmation', :with => "newemail@notcredda.com"
          # Current Password
          fill_in 'customer_current_password', :with => customer.password

          click_button 'Save Account Changes'
        end
        
        page.should have_css("#flash-messages")
        message = YAML.load_file("#{Rails.root}/config/locales/devise.en.yml")['en']['devise']['registrations']['update_needs_confirmation']
        page.should have_content(message)
        current_path.should eq(customer_home_path)

        customer.reload
        customer.email.should_not eq("newemail@notcredda.com")
        customer.unconfirmed_email.should eq("newemail@notcredda.com")

        last_email.to.should eq([customer.unconfirmed_email])
        last_email.body.should match(/confirm your account email/)
      end
    end

    describe "valid password change" do
      it "edits customer information" do
        within("#edit-registration") do
          # Account information
          fill_in 'customer_password', :with => "brandnewpass"
          fill_in 'customer_password_confirmation', :with => "brandnewpass"
          # Current Password
          fill_in 'customer_current_password', :with => customer.password

          click_button 'Save Account Changes'
        end
        
        page.should have_css("#flash-messages")
        message = YAML.load_file("#{Rails.root}/config/locales/devise.en.yml")['en']['devise']['registrations']['updated']
        page.should have_content(message)
        current_path.should eq(customer_home_path)

        old_password = customer.encrypted_password
        customer.reload
        customer.encrypted_password.should_not eq(old_password)
      end
    end

    describe "invalid password change (mismatch)" do
      it "edits customer information" do
        within("#edit-registration") do
          # Account information
          fill_in 'customer_password', :with => "brandnewpass"
          fill_in 'customer_password_confirmation', :with => "mismatch"
          # Current Password
          fill_in 'customer_current_password', :with => customer.password

          click_button 'Save Account Changes'
        end
        
        page.should have_css("#flash-messages")
        page.should have_content("doesn't match confirmation")
        current_path.should eq(customer_registration_path)

        old_password = customer.encrypted_password
        customer.reload
        customer.encrypted_password.should eq(old_password)
      end
    end

    describe "invalid password change (without current password)" do
      it "edits customer information" do
        within("#edit-registration") do
          # Account information
          fill_in 'customer_password', :with => "brandnewpass"
          fill_in 'customer_password_confirmation', :with => "brandnewpass"

          click_button 'Save Account Changes'
        end
        
        page.should have_css("#flash-messages")
        page.should have_content("can't be blank")
        current_path.should eq(customer_registration_path)

        old_password = customer.encrypted_password
        customer.reload
        customer.encrypted_password.should eq(old_password)
      end
    end
  end
end