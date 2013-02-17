require 'spec_helper'

describe "password reset" do
  context "as anonymous" do
    include_context "as anonymous"
    let(:customer) { FactoryGirl.create(:customer) }
    before(:each) do
      visit new_customer_password_path
    end

    describe "with valid attributes" do
      it "sends password reset email" do
        within("#new-password") do
          fill_in 'customer_email', :with => customer.email
          click_button 'Reset Password'
        end
        
        last_email.to.should eq([customer.email])
        last_email.from.should eq(["no-reply@credda.com"])
        subject = YAML.load_file("#{Rails.root}/config/locales/devise.en.yml")['en']['devise']['mailer']['reset_password_instructions']['subject']
        last_email.subject.should eq(subject)
      end      

      it "redirects to sign in page" do
        within("#new-password") do
          fill_in 'customer_email', :with => customer.email
          click_button 'Reset Password'
        end
        
        current_path.should eq(new_customer_session_path)
        page.should have_css("#flash-messages")
        message = YAML.load_file("#{Rails.root}/config/locales/devise.en.yml")['en']['devise']['passwords']['send_instructions']
        page.should have_content(message)          
      end      
    end

    describe "with invalid email" do
      it "does not send email" do
        within("#new-password") do
          fill_in 'customer_email', :with => "invalid@email.com"
          click_button 'Reset Password'
        end
        
        last_email.should be_nil
      end

      it "reloads password page" do
        within("#new-password") do
          fill_in 'customer_email', :with => "invalid@email.com"
          click_button 'Reset Password'
        end
        
        current_path.should eq(customer_password_path)
        page.should have_css("#flash-messages")
        message = "not found"
        page.should have_content(message)          
      end      
    end
  end

  context "as customer" do
    include_context "as customer"

    it "redirects to customer home" do
      visit new_customer_password_path
      current_path.should eq(customer_home_path)
    end
  end
end