require 'spec_helper'

describe "unlock account" do
  # Feature Shared Methods
  #----------------------------------------------------------------------------

  # As Unauthenticated Store
  #----------------------------------------------------------------------------
  context "as unauthenticated store", :unauthenticated => true do
    include_context "as unauthenticated store"
    before(:each) do
      visit new_store_unlock_path
    end

    describe "with valid attributes" do
      it "does not take unlock actions" do
        within("#unlock") do
          fill_in 'store_email', :with => store.email
          click_button 'Send Unlock Instructions'
        end
        
        # Page
        has_error(:devise, :not_locked)
        no_flash
        current_path.should eq(store_unlock_path)
        
        # Object
        
        # External Behavior
        no_email_sent
      end      
    end

    describe "with invalid email" do
      it "does not take unlock actions" do
        within("#unlock") do
          fill_in 'store_email', :with => "invalid@email.com"
          click_button 'Send Unlock Instructions'
        end
        
        # Page
        has_error(:devise, :not_found)
        no_flash
        current_path.should eq(store_unlock_path)
        
        # Object
        
        # External Behavior
        no_email_sent
      end      
    end
  end
    
  # As Unconfirmed Customer
  #----------------------------------------------------------------------------
  context "as locked store", :locked => true do
    include_context "as locked store"
    before(:each) do
      visit new_store_unlock_path
    end

    describe "with valid attributes" do
      it "redirects to sign in page" do
        within("#unlock") do
          fill_in 'store_email', :with => store.email
          click_button 'Send Unlock Instructions'
        end
        
        # Page
        flash_set(:notice, :devise, :unlock_account)
        current_path.should eq(new_store_session_path)
        
        # Object
        
        # External Behavior
        unlock_email_sent_to(store.email, store.unlock_token)
      end      
    end

    describe "with invalid email" do
      it "reloads unlock page" do
        within("#unlock") do
          fill_in 'store_email', :with => "invalid@email.com"
          click_button 'Send Unlock Instructions'
        end
        
        # Page
        has_error(:devise, :not_found)
        no_flash
        current_path.should eq(store_unlock_path)
        
        # Object
        
        # External Behavior
        no_email_sent
      end      
    end    
  end
  
  # As Locked
  #----------------------------------------------------------------------------
  context "as locked store", :locked => true do
    include_context "as locked store"
    before(:each) do
      visit new_store_unlock_path
    end

    describe "with valid attributes" do
      it "redirects to sign in page" do
        within("#unlock") do
          fill_in 'store_email', :with => store.email
          click_button 'Send Unlock Instructions'
        end
        
        # Page
        flash_set(:notice, :devise, :unlock_account)
        current_path.should eq(new_store_session_path)
        
        # Object
        
        # External Behavior
        unlock_email_sent_to(store.email, store.unlock_token)
      end      
    end

    describe "with invalid email" do
      it "reloads unlock page" do
        within("#unlock") do
          fill_in 'store_email', :with => "invalid@email.com"
          click_button 'Send Unlock Instructions'
        end
        
        # Page
        has_error(:devise, :not_found)
        no_flash
        current_path.should eq(store_unlock_path)
        
        # Object
        
        # External Behavior
        no_email_sent
      end      
    end    
  end
  
  # As Authenticated
  #----------------------------------------------------------------------------
  context "as authenticated store" do
    include_context "as authenticated store"
    before(:each) do
      visit new_store_unlock_path
    end

    it "redirects to store home" do
      current_path.should eq(store_home_path)
    end
  end

  # As Customer
  #----------------------------------------------------------------------------
  context "as authenticated customer" do
    include_context "as authenticated customer"
    before(:each) do
      visit new_store_unlock_path
    end

    it "redirects to store home" do
      current_path.should eq(store_scope_conflict_path)
    end
  end

  # As Employee
  #----------------------------------------------------------------------------
  context "as authenticated employee" do
    include_context "as authenticated employee"
    before(:each) do
      visit new_store_unlock_path
    end

    it "redirects to store home" do
      current_path.should eq(store_scope_conflict_path)
    end
  end
end