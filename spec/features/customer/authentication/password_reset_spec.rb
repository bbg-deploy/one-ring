require 'spec_helper'

describe "password reset" do
  # Feature Shared Methods
  #----------------------------------------------------------------------------

  # As Unauthenticated Customer
  #----------------------------------------------------------------------------
  context "as unauthenticated customer", :unauthenticated => true do
    include_context "as unauthenticated customer"
    before(:each) do
      visit new_customer_password_path
    end

    describe "with valid attributes", :failing => true do
      it "sends password reset email" do
        within("#new-password") do
          fill_in 'customer_email', :with => customer.email
          click_button 'Reset Password'
        end
        
        # Page
        flash_set(:notice, :devise, :password_reset)
        current_path.should eq(new_customer_session_path)
        
        # Object
        customer.reload
        customer.reset_password_token.should_not be_nil
        
        # External Behavior
        password_reset_email_sent_to(customer.email, customer.reset_password_token)
      end      
    end

    describe "with invalid email" do
      it "does not reset email" do
        within("#new-password") do
          fill_in 'customer_email', :with => "invalid@email.com"
          click_button 'Reset Password'
        end

        # Page
        no_flash
        has_error(:devise, :not_found)
        current_path.should eq(customer_password_path)
        
        # Object
        customer.reload
        customer.reset_password_token.should be_nil
        
        # External Behavior
        no_email_sent
      end
    end
  end

  # As Unconfirmed Customer
  #----------------------------------------------------------------------------
  context "as unconfirmed customer", :unconfirmed => true do
    include_context "as unconfirmed customer"
    before(:each) do
      visit new_customer_password_path
    end

    describe "with valid attributes", :failing => true do
      it "sends password reset email" do
        within("#new-password") do
          fill_in 'customer_email', :with => customer.email
          click_button 'Reset Password'
        end
        
        # Page
        flash_set(:notice, :devise, :password_reset)
        current_path.should eq(new_customer_session_path)
        
        # Object
        customer.reload
        customer.reset_password_token.should_not be_nil
        
        # External Behavior
        password_reset_email_sent_to(customer.email, customer.reset_password_token)
      end      
    end

    describe "with invalid email" do
      it "does not reset email" do
        within("#new-password") do
          fill_in 'customer_email', :with => "invalid@email.com"
          click_button 'Reset Password'
        end

        # Page
        no_flash
        has_error(:devise, :not_found)
        current_path.should eq(customer_password_path)
        
        # Object
        customer.reload
        customer.reset_password_token.should be_nil
        
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
      visit new_customer_password_path
    end

    describe "with valid attributes", :failing => true do
      it "sends password reset email" do
        within("#new-password") do
          fill_in 'customer_email', :with => customer.email
          click_button 'Reset Password'
        end
        
        # Page
        flash_set(:notice, :devise, :password_reset)
        current_path.should eq(new_customer_session_path)
        
        # Object
        customer.reload
        customer.reset_password_token.should_not be_nil
        
        # External Behavior
        password_reset_email_sent_to(customer.email, customer.reset_password_token)
      end      
    end

    describe "with invalid email" do
      it "does not reset email" do
        within("#new-password") do
          fill_in 'customer_email', :with => "invalid@email.com"
          click_button 'Reset Password'
        end

        # Page
        no_flash
        has_error(:devise, :not_found)
        current_path.should eq(customer_password_path)
        
        # Object
        customer.reload
        customer.reset_password_token.should be_nil
        
        # External Behavior
        no_email_sent
      end
    end
  end

  # As Authenticated Customer
  #----------------------------------------------------------------------------
  context "as authenticated customer" do
    include_context "as authenticated customer"
    before(:each) do
      visit new_customer_password_path
    end

    it "redirects to customer home" do
      current_path.should eq(customer_home_path)
    end
  end

  # As Store
  #----------------------------------------------------------------------------
  context "as authenticated store", :store => true do
    include_context "as authenticated store"
    before(:each) do
      visit new_customer_password_path
    end

    it "redirects to customer scope conflict" do
      current_path.should eq(customer_scope_conflict_path)
    end
  end

  # As Employee
  #----------------------------------------------------------------------------
  context "as authenticated employee", :employee => true do
    include_context "as authenticated employee"
    before(:each) do
      visit new_customer_password_path
    end

    it "redirects to customer scope conflict" do
      current_path.should eq(customer_scope_conflict_path)
    end
  end
end