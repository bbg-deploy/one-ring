require 'spec_helper'

describe "edit_account" do
  # Feature Shared Methods
  #----------------------------------------------------------------------------

  # As Unauthenticated Customer
  #----------------------------------------------------------------------------
  context "as unauthenticated customer", :unauthenticated => true do
    include_context "as unauthenticated customer"
    before(:each) do
      visit edit_customer_registration_path
    end

    it "redirects to customer login" do
      flash_set(:alert, :devise, :unauthenticated)
      current_path.should eq(new_customer_session_path)
    end
  end

  # As Authenticated Customer
  #----------------------------------------------------------------------------
  context "as authenticated customer", :authenticated => true do
    include_context "as authenticated customer"
    before(:each) do
      visit edit_customer_registration_path
    end
    
    describe "valid name change" do
      describe "successful Authorize.net response" do
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
            
            # Page
            flash_set(:notice, :devise, :updated_registration)
            current_path.should eq(customer_home_path)

            # Customer
            customer.reload
            customer.first_name.should eq("Dick")
            customer.last_name.should eq("Tracy")

            # External Behavior
            no_email_sent
            made_authorize_net_request("updateCustomerProfileRequest")
          end
        end
      end

      describe "unsuccessful Authorize.net response" do
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
            
            # Page
            flash_set(:alert, :devise, :authorize_net_error)
            current_path.should eq(edit_customer_registration_path)

            # Customer
            customer.reload
            customer.first_name.should_not eq("Dick")
            customer.last_name.should_not eq("Tracy")

            # External Behavior
            made_authorize_net_request("updateCustomerProfileRequest")
            admin_email_alert
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
        
        # Page
        flash_set(:notice, :devise, :updated_registration_needs_confirmation)
        current_path.should eq(customer_home_path)

        # Customer
        customer.reload
        customer.email.should_not eq("newemail@notcredda.com")
        customer.unconfirmed_email.should eq("newemail@notcredda.com")

        # External Behavior
        confirmation_email_sent_to(customer.unconfirmed_email, customer.confirmation_token)
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
        
        # Page
        flash_set(:notice, :devise, :updated_registration)
        current_path.should eq(customer_home_path)

        # Customer
        old_password = customer.encrypted_password
        customer.reload
        customer.encrypted_password.should_not eq(old_password)

        # External Behavior
        no_email_sent      
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
        
        # Page
        flash_set(:alert, :devise, :invalid_data)
        has_error(:custom, :confirmation_mismatch)
        current_path.should eq(customer_registration_path)

        # Customer
        old_password = customer.encrypted_password
        customer.reload
        customer.encrypted_password.should eq(old_password)

        # External Behavior
        no_email_sent        
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
        
        # Page
        flash_set(:alert, :devise, :invalid_data)
        has_error(:custom, :blank)
        current_path.should eq(customer_registration_path)

        # Customer
        old_password = customer.encrypted_password
        customer.reload
        customer.encrypted_password.should eq(old_password)

        # External Behavior
        no_email_sent        
      end
    end
  end

  # As Store
  #----------------------------------------------------------------------------
  context "as authenticated store" do
    include_context "as authenticated store"
    before(:each) do
      visit edit_customer_registration_path
    end

    it "redirects to customer scope conflict" do
      current_path.should eq(customer_scope_conflict_path)
    end
  end

  # As Employee
  #----------------------------------------------------------------------------
  context "as authenticated employee" do
    include_context "as authenticated employee"
    before(:each) do
      visit edit_customer_registration_path
    end

    it "redirects to customer scope conflict" do
      current_path.should eq(customer_scope_conflict_path)
    end
  end
end