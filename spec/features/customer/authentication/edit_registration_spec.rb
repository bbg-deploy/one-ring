require 'spec_helper'

describe "edit_account" do
  context "as anonymous", :anonymous => true do
    include_context "as anonymous"
    before(:each) do
      visit edit_customer_registration_path
    end

    it "redirects to customer home" do
      current_path.should eq(new_customer_session_path)
    end
  end

  context "as customer", :authenticated => true do
    include_context "as customer"
    before(:each) do
      visit edit_customer_registration_path
    end

    describe "name change" do
      it "edits customer information" do
        within("#edit-registration") do
          # Account information
#          fill_in 'customer_username', :with => customer.username
#          fill_in 'customer_password', :with => customer.password
#          fill_in 'customer_password_confirmation', :with => customer.password
#          fill_in 'customer_email', :with => customer.email
#          fill_in 'customer_email_confirmation', :with => customer.email
          # Personal Information
          fill_in 'customer_first_name', :with => "Dick"
          fill_in 'customer_middle_name', :with => customer.middle_name
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
      end

      it "persists changes" do
        within("#edit-registration") do
          fill_in 'customer_first_name', :with => "Dick"
          fill_in 'customer_last_name', :with => "Tracy"
          # Current Password
          fill_in 'customer_current_password', :with => customer.password

          click_button 'Save Account Changes'
        end
        
        customer.reload
        customer.first_name.should eq("Dick")
        customer.last_name.should eq("Tracy")
      end
    end

    describe "email change" do
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
      end

      it "persists changes" do
        within("#edit-registration") do
          # Account information
          fill_in 'customer_email', :with => "newemail@notcredda.com"
          fill_in 'customer_email_confirmation', :with => "newemail@notcredda.com"
          # Current Password
          fill_in 'customer_current_password', :with => customer.password

          click_button 'Save Account Changes'
        end
        
        customer.reload
        customer.email.should_not eq("newemail@notcredda.com")
        customer.unconfirmed_email.should eq("newemail@notcredda.com")
      end
    end

    describe "password change" do
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
      end

      it "persists changes" do
        within("#edit-registration") do
          # Account information
          fill_in 'customer_password', :with => "brandnewpass"
          fill_in 'customer_password_confirmation', :with => "brandnewpass"
          # Current Password
          fill_in 'customer_current_password', :with => customer.password

          click_button 'Save Account Changes'
        end
        
        old_password = customer.encrypted_password
        customer.reload
        customer.encrypted_password.should_not eq(old_password)
      end
    end
  end
end