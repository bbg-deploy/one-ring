require 'spec_helper'

describe "password reset" do
  # Feature Shared Methods
  #----------------------------------------------------------------------------

  # As Unauthenticated Store
  #----------------------------------------------------------------------------
  context "as unauthenticated store", :unauthenticated => true do
    include_context "as unauthenticated store"
    before(:each) do
      visit new_store_password_path
    end

    describe "with valid attributes", :failing => true do
      it "sends password reset email" do
        within("#new-password") do
          fill_in 'store_email', :with => store.email
          click_button 'Reset Password'
        end
        
        # Page
        flash_set(:notice, :devise, :password_reset)
        current_path.should eq(new_store_session_path)
        
        # Object
        store.reload
        store.reset_password_token.should_not be_nil
        
        # External Behavior
        password_reset_email_sent_to(store.email, store.reset_password_token)
      end      
    end

    describe "with invalid email" do
      it "does not reset email" do
        within("#new-password") do
          fill_in 'store_email', :with => "invalid@email.com"
          click_button 'Reset Password'
        end

        # Page
        no_flash
        has_error(:devise, :not_found)
        current_path.should eq(store_password_path)
        
        # Object
        store.reload
        store.reset_password_token.should be_nil
        
        # External Behavior
        no_email_sent
      end
    end
  end

  # As Unconfirmed Customer
  #----------------------------------------------------------------------------
  context "as unconfirmed store", :unconfirmed => true do
    include_context "as unconfirmed store"
    before(:each) do
      visit new_store_password_path
    end

    describe "with valid attributes", :failing => true do
      it "sends password reset email" do
        within("#new-password") do
          fill_in 'store_email', :with => store.email
          click_button 'Reset Password'
        end
        
        # Page
        flash_set(:notice, :devise, :password_reset)
        current_path.should eq(new_store_session_path)
        
        # Object
        store.reload
        store.reset_password_token.should_not be_nil
        
        # External Behavior
        password_reset_email_sent_to(store.email, store.reset_password_token)
      end      
    end

    describe "with invalid email" do
      it "does not reset email" do
        within("#new-password") do
          fill_in 'store_email', :with => "invalid@email.com"
          click_button 'Reset Password'
        end

        # Page
        no_flash
        has_error(:devise, :not_found)
        current_path.should eq(store_password_path)
        
        # Object
        store.reload
        store.reset_password_token.should be_nil
        
        # External Behavior
        no_email_sent
      end
    end
  end

  # As Locked Customer
  #----------------------------------------------------------------------------
  context "as locked store", :locked => true do
    include_context "as locked store"
    before(:each) do
      visit new_store_password_path
    end

    describe "with valid attributes", :failing => true do
      it "sends password reset email" do
        within("#new-password") do
          fill_in 'store_email', :with => store.email
          click_button 'Reset Password'
        end
        
        # Page
        flash_set(:notice, :devise, :password_reset)
        current_path.should eq(new_store_session_path)
        
        # Object
        store.reload
        store.reset_password_token.should_not be_nil
        
        # External Behavior
        password_reset_email_sent_to(store.email, store.reset_password_token)
      end      
    end

    describe "with invalid email" do
      it "does not reset email" do
        within("#new-password") do
          fill_in 'store_email', :with => "invalid@email.com"
          click_button 'Reset Password'
        end

        # Page
        no_flash
        has_error(:devise, :not_found)
        current_path.should eq(store_password_path)
        
        # Object
        store.reload
        store.reset_password_token.should be_nil
        
        # External Behavior
        no_email_sent
      end
    end
  end

  # As Authenticated Customer
  #----------------------------------------------------------------------------
  context "as authenticated store" do
    include_context "as authenticated store"
    before(:each) do
      visit new_store_password_path
    end

    it "redirects to store home" do
      current_path.should eq(store_home_path)
    end
  end

  # As Customer
  #----------------------------------------------------------------------------
  context "as authenticated customer", :customer => true do
    include_context "as authenticated customer"
    before(:each) do
      visit new_store_password_path
    end

    it "redirects to store scope conflict" do
      current_path.should eq(store_scope_conflict_path)
    end
  end

  # As Employee
  #----------------------------------------------------------------------------
  context "as authenticated employee", :employee => true do
    include_context "as authenticated employee"
    before(:each) do
      visit new_store_password_path
    end

    it "redirects to store scope conflict" do
      current_path.should eq(store_scope_conflict_path)
    end
  end
end