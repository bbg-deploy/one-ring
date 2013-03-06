require 'spec_helper'

describe "sign in" do
  # Feature Shared Methods
  #----------------------------------------------------------------------------

  # As Unauthenticated Store
  #----------------------------------------------------------------------------
  context "as unauthenticated store", :unauthenticated => true do
    include_context "as unauthenticated store"
    before(:each) do
      visit new_store_session_path
    end

    context "with valid credentials" do
      it "logs in store with username" do
        within("#new-session") do
          fill_in 'store_login', :with => store.username
          fill_in 'store_password', :with => store.password
          click_button 'Sign in'
        end

        # Page
        flash_set(:notice, :devise, :signed_in)
        current_path.should eq(store_home_path)
        
        # Object
        
        # External Behavior
        no_email_sent
      end      

      it "logs in store with email" do
        within("#new-session") do
          fill_in 'store_login', :with => store.email
          fill_in 'store_password', :with => store.password
          click_button 'Sign in'
        end

        # Page
        flash_set(:notice, :devise, :signed_in)
        current_path.should eq(store_home_path)
        
        # Object
        
        # External Behavior
        no_email_sent
      end      
    end

    context "with invalid credentials" do
      it "reloads sign-in page" do
        within("#new-session") do
          fill_in 'store_login', :with => store.email
          fill_in 'store_password', :with => "incorrect"
          click_button 'Sign in'
        end

        # Page
        flash_set(:alert, :devise, :invalid)
        current_path.should eq(new_store_session_path)
        
        # Object
        
        # External Behavior
        no_email_sent
      end
    end
  end

  # As Unauthenticated Customer
  #----------------------------------------------------------------------------
  context "as unconfirmed store", :unconfirmed => true do
    include_context "as unconfirmed store"
    before(:each) do
      visit new_store_session_path
    end

    context "with valid credentials" do
      it "does not sign in" do
        within("#new-session") do
          fill_in 'store_login', :with => store.email
          fill_in 'store_password', :with => store.password
          click_button 'Sign in'
        end

        # Page
        flash_set(:alert, :devise, :unconfirmed)
        current_path.should eq(new_store_session_path)
        
        # Object
        
        # External Behavior
        no_email_sent
      end
    end

    context "with invalid credentials" do
      before(:each) do
        visit new_store_session_path
      end
      
      it "does not sign in" do
        within("#new-session") do
          fill_in 'store_login', :with => store.email
          fill_in 'store_password', :with => "incorrect"
          click_button 'Sign in'
        end

        # Page
        flash_set(:alert, :devise, :invalid)
        current_path.should eq(new_store_session_path)
        
        # Object
        
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
      visit new_store_session_path
    end
      
    context "with valid credentials" do
      it "does not log in store" do
        within("#new-session") do
          fill_in 'store_login', :with => store.email
          fill_in 'store_password', :with => store.password
          click_button 'Sign in'
        end

        # Page
        flash_set(:alert, :devise, :invalid)
        current_path.should eq(new_store_session_path)
        
        # Object
        
        # External Behavior
        no_email_sent
      end      
    end
    
    context "with invalid credentials" do
      it "reloads sign-in page" do
        within("#new-session") do
          fill_in 'store_login', :with => store.email
          fill_in 'store_password', :with => "incorrect"
          click_button 'Sign in'
        end

        # Page
        flash_set(:alert, :devise, :invalid)
        current_path.should eq(new_store_session_path)
        
        # Object
        
        # External Behavior
        no_email_sent
      end
    end
  end
  
  # As Authenticated Customer
  #----------------------------------------------------------------------------
  context "as authenticated store", :authenticated => true do
    include_context "as authenticated store"
    before(:each) do
      visit new_store_session_path
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
      visit new_store_session_path
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
      visit new_store_session_path
    end

    it "redirects to store home" do
      current_path.should eq(store_scope_conflict_path)
    end
  end
end