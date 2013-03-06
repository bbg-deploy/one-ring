require 'spec_helper'

describe "password reset" do
  # Feature Shared Methods
  #----------------------------------------------------------------------------

  # As Anonymous
  #----------------------------------------------------------------------------
  context "as anonymous" do
    include_context "as anonymous"
    let!(:customer) { FactoryGirl.create(:customer) }
    before(:each) do
      reset_email
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

  # As Customer
  #----------------------------------------------------------------------------
  context "as customer" do
    include_context "as customer"
    before(:each) do
      visit new_customer_password_path
    end

    it "redirects to customer home" do
      current_path.should eq(customer_home_path)
    end
  end

  # As Store
  #----------------------------------------------------------------------------
  context "as store", :store => true do
    include_context "as store"
    before(:each) do
      visit new_customer_password_path
    end

    it "redirects to customer scope conflict" do
      current_path.should eq(customer_scope_conflict_path)
    end
  end

  # As Employee
  #----------------------------------------------------------------------------
  context "as employee", :employee => true do
    include_context "as employee"
    before(:each) do
      visit new_customer_password_path
    end

    it "redirects to customer scope conflict" do
      current_path.should eq(customer_scope_conflict_path)
    end
  end
end