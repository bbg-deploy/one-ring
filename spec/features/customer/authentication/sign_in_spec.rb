require 'spec_helper'

describe "sign in" do
  # Feature Shared Methods
  #----------------------------------------------------------------------------

  # As Unauthenticated Customer
  #----------------------------------------------------------------------------
  context "as unauthenticated customer", :unauthenticated => true do
    include_context "as unauthenticated customer"
    before(:each) do
      visit new_customer_session_path
    end

    context "with valid credentials" do
      it "logs in customer with username" do
        within("#new-session") do
          fill_in 'customer_login', :with => customer.username
          fill_in 'customer_password', :with => customer.password
          click_button 'Sign in'
        end

        # Page
        flash_set(:notice, :devise, :signed_in)
        current_path.should eq(customer_home_path)
        
        # Object
        
        # External Behavior
        no_email_sent
      end      

      it "logs in customer with email" do
        within("#new-session") do
          fill_in 'customer_login', :with => customer.email
          fill_in 'customer_password', :with => customer.password
          click_button 'Sign in'
        end

        # Page
        flash_set(:notice, :devise, :signed_in)
        current_path.should eq(customer_home_path)
        
        # Object
        
        # External Behavior
        no_email_sent
      end      
    end

    context "with invalid credentials" do
      it "reloads sign-in page" do
        within("#new-session") do
          fill_in 'customer_login', :with => customer.email
          fill_in 'customer_password', :with => "incorrect"
          click_button 'Sign in'
        end

        # Page
        flash_set(:alert, :devise, :invalid)
        current_path.should eq(new_customer_session_path)
        
        # Object
        
        # External Behavior
        no_email_sent
      end
    end
  end

  # As Unauthenticated Customer
  #----------------------------------------------------------------------------
  context "as unconfirmed customer", :unconfirmed => true do
    include_context "as unconfirmed customer"
    before(:each) do
      visit new_customer_session_path
    end

    context "with valid credentials" do
      it "does not sign in" do
        within("#new-session") do
          fill_in 'customer_login', :with => customer.email
          fill_in 'customer_password', :with => customer.password
          click_button 'Sign in'
        end

        # Page
        flash_set(:alert, :devise, :unconfirmed)
        current_path.should eq(new_customer_session_path)
        
        # Object
        
        # External Behavior
        no_email_sent
      end
    end

    context "with invalid credentials" do
      before(:each) do
        customer.confirm!
        reset_email
        visit new_customer_session_path
      end
      
      it "does not sign in" do
        within("#new-session") do
          fill_in 'customer_login', :with => customer.email
          fill_in 'customer_password', :with => "incorrect"
          click_button 'Sign in'
        end

        # Page
        flash_set(:alert, :devise, :invalid)
        current_path.should eq(new_customer_session_path)
        
        # Object
        
        # External Behavior
        no_email_sent
      end
    end
  end

  # As Locked Customer
  #----------------------------------------------------------------------------
  context "as locked customer", :locked => true do
    include_context "as locked customer"
    before(:each) do
      visit new_customer_session_path
    end
      
    context "with valid credentials" do
      it "does not log in customer" do
        within("#new-session") do
          fill_in 'customer_login', :with => customer.email
          fill_in 'customer_password', :with => customer.password
          click_button 'Sign in'
        end

        # Page
        flash_set(:alert, :devise, :invalid)
        current_path.should eq(new_customer_session_path)
        
        # Object
        
        # External Behavior
        no_email_sent
      end      
    end
    
    context "with invalid credentials" do
      it "reloads sign-in page" do
        within("#new-session") do
          fill_in 'customer_login', :with => customer.email
          fill_in 'customer_password', :with => "incorrect"
          click_button 'Sign in'
        end

        # Page
        flash_set(:alert, :devise, :invalid)
        current_path.should eq(new_customer_session_path)
        
        # Object
        
        # External Behavior
        no_email_sent
      end
    end
  end
  
  # As Authenticated Customer
  #----------------------------------------------------------------------------
  context "as authenticated customer", :authenticated => true do
    include_context "as authenticated customer"
    before(:each) do
      visit new_customer_session_path
    end

    it "redirects to customer home" do
      current_path.should eq(customer_home_path)
    end
  end

  # As Store
  #----------------------------------------------------------------------------
  context "as authenticated store" do
    include_context "as authenticated store"
    before(:each) do
      visit new_customer_session_path
    end

    it "redirects to customer home" do
      current_path.should eq(customer_scope_conflict_path)
    end
  end

  # As Employee
  #----------------------------------------------------------------------------
  context "as authenticated employee" do
    include_context "as authenticated employee"
    before(:each) do
      visit new_customer_session_path
    end

    it "redirects to customer home" do
      current_path.should eq(customer_scope_conflict_path)
    end
  end
end