require 'spec_helper'

describe "edit_account" do
  # Feature Shared Methods
  #----------------------------------------------------------------------------

  # As Unauthenticated Customer
  #----------------------------------------------------------------------------
  context "as unauthenticated store", :unauthenticated => true do
    include_context "as unauthenticated store"
    before(:each) do
      visit edit_store_registration_path
    end

    it "redirects to store login" do
      flash_set(:alert, :devise, :unauthenticated)
      current_path.should eq(new_store_session_path)
    end
  end

  # As Authenticated Store
  #----------------------------------------------------------------------------
  context "as authenticated store", :authenticated => true do
    include_context "as authenticated store"
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
        
        # Page
        flash_set(:notice, :devise, :updated_registration)
        current_path.should eq(store_home_path)
  
        # Store
        store.reload
        store.name.should eq("Gorilla Industries")
  
        # External Behavior
        no_email_sent
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
        
        # Page
        flash_set(:notice, :devise, :updated_registration_needs_confirmation)
        current_path.should eq(store_home_path)

        # Customer
        store.reload
        store.email.should_not eq("newemail@notcredda.com")
        store.unconfirmed_email.should eq("newemail@notcredda.com")

        # External Behavior
        confirmation_email_sent_to("newemail@notcredda.com", store.confirmation_token).should be_true
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
        
        # Page
        flash_set(:notice, :devise, :updated_registration)
        current_path.should eq(store_home_path)

        # Customer
        old_password = store.encrypted_password
        store.reload
        store.encrypted_password.should_not eq(old_password)

        # External Behavior
        no_email_sent      
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
        
        # Page
        flash_set(:alert, :devise, :invalid_data)
        has_error(:custom, :confirmation_mismatch)
        current_path.should eq(store_registration_path)

        # Customer
        old_password = store.encrypted_password
        store.reload
        store.encrypted_password.should eq(old_password)

        # External Behavior
        no_email_sent        
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
        
        # Page
        flash_set(:alert, :devise, :invalid_data)
        has_error(:custom, :blank)
        current_path.should eq(store_registration_path)

        # Customer
        old_password = store.encrypted_password
        store.reload
        store.encrypted_password.should eq(old_password)

        # External Behavior
        no_email_sent        
      end
    end
  end

  # As Customer
  #----------------------------------------------------------------------------
  context "as authenticated customer" do
    include_context "as authenticated customer"
    before(:each) do
      visit edit_store_registration_path
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
      visit edit_store_registration_path
    end

    it "redirects to store scope conflict" do
      current_path.should eq(store_scope_conflict_path)
    end
  end
end