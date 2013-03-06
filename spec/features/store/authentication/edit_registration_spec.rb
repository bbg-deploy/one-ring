require 'spec_helper'

describe "edit_account" do
  # Feature Shared Methods
  #----------------------------------------------------------------------------

  # As Anonymous
  #----------------------------------------------------------------------------
  context "as anonymous", :anonymous => true do
    include_context "as anonymous"
    before(:each) do
      visit edit_store_registration_path
    end

    it "redirects to store login" do
      current_path.should eq(new_store_session_path)
    end
  end

  # As Customer
  #----------------------------------------------------------------------------
  context "as store", :authenticated => true do
    include_context "as store"
    before(:each) do
      visit edit_store_registration_path
    end
    
    describe "valid name change" do
      it "edits store information" do
        within("#edit-registration") do
          fill_in 'store_name', :with => "Gorilla Industries"
          # Current Password
          fill_in 'store_current_password', :with => store.password

          click_button 'Save Account Changes'
        end
        
        page.should have_css("#flash-messages")
        message = YAML.load_file("#{Rails.root}/config/locales/devise.en.yml")['en']['devise']['registrations']['updated']
        page.should have_content(message)
        current_path.should eq(store_home_path)

        store.reload
        store.name.should eq("Gorilla Industries")
      end
    end

    describe "valid email change" do
      it "edits store information" do
        within("#edit-registration") do
          # Account information
          fill_in 'store_email', :with => "newemail@notcredda.com"
          fill_in 'store_email_confirmation', :with => "newemail@notcredda.com"
          # Current Password
          fill_in 'store_current_password', :with => store.password

          click_button 'Save Account Changes'
        end
        
        page.should have_css("#flash-messages")
        message = YAML.load_file("#{Rails.root}/config/locales/devise.en.yml")['en']['devise']['registrations']['update_needs_confirmation']
        page.should have_content(message)
        current_path.should eq(store_home_path)

        store.reload
        store.email.should_not eq("newemail@notcredda.com")
        store.unconfirmed_email.should eq("newemail@notcredda.com")

        last_email.to.should eq([store.unconfirmed_email])
        last_email.body.should match(/confirm your account email/)
      end
    end

    describe "valid password change" do
      it "edits store information" do
        within("#edit-registration") do
          # Account information
          fill_in 'store_password', :with => "brandnewpass"
          fill_in 'store_password_confirmation', :with => "brandnewpass"
          # Current Password
          fill_in 'store_current_password', :with => store.password

          click_button 'Save Account Changes'
        end
        
        page.should have_css("#flash-messages")
        message = YAML.load_file("#{Rails.root}/config/locales/devise.en.yml")['en']['devise']['registrations']['updated']
        page.should have_content(message)
        current_path.should eq(store_home_path)

        old_password = store.encrypted_password
        store.reload
        store.encrypted_password.should_not eq(old_password)
      end
    end

    describe "invalid password change (mismatch)" do
      it "edits store information" do
        within("#edit-registration") do
          # Account information
          fill_in 'store_password', :with => "brandnewpass"
          fill_in 'store_password_confirmation', :with => "mismatch"
          # Current Password
          fill_in 'store_current_password', :with => store.password

          click_button 'Save Account Changes'
        end
        
        page.should have_css("#flash-messages")
        page.should have_content("doesn't match confirmation")
        current_path.should eq(store_registration_path)

        old_password = store.encrypted_password
        store.reload
        store.encrypted_password.should eq(old_password)
      end
    end

    describe "invalid password change (without current password)" do
      it "edits store information" do
        within("#edit-registration") do
          # Account information
          fill_in 'store_password', :with => "brandnewpass"
          fill_in 'store_password_confirmation', :with => "brandnewpass"

          click_button 'Save Account Changes'
        end
        
        page.should have_css("#flash-messages")
        page.should have_content("can't be blank")
        current_path.should eq(store_registration_path)

        old_password = store.encrypted_password
        store.reload
        store.encrypted_password.should eq(old_password)
      end
    end
  end
end