require 'spec_helper'

describe "unlock account" do
  context "anonymous", :anonymous => true do
    include_context "as anonymous visitor"
    let(:customer) { FactoryGirl.create(:customer) }
    before(:each) do
      visit new_customer_unlock_path
    end
    
    context "unlocked" do
      describe "with valid attributes" do
        it "does not send unlock email" do
          #TODO: Find a better way to test this
        end
  
        it "reloads unlock page" do
          within("#customer-unlock") do
            fill_in 'customer_email', :with => customer.email
            click_button 'Resend unlock instructions'
          end
          
          current_path.should eq(customer_unlock_path)
          page.should have_css("#flash-messages")
          message = YAML.load_file("#{Rails.root}/config/locales/devise.en.yml")['en']['errors']['messages']['not_locked']
          page.should have_content(message)          
        end      
      end
  
      describe "with invalid email" do
        it "does not send unlock email" do
          #TODO: Find a better way to test this
        end      
  
        it "reloads unlock page" do
          within("#customer-unlock") do
            fill_in 'customer_email', :with => "invalid@email.com"
            click_button 'Resend unlock instructions'
          end
          
          current_path.should eq(customer_unlock_path)
          page.should have_css("#flash-messages")
          message = "not found"
          page.should have_content(message)          
        end      
      end
    end
    
    context "locked" do
      before(:each) do
        customer.lock_access!
      end

      describe "with valid attributes" do
        it "sends unlock reset email" do
          within("#customer-unlock") do
            fill_in 'customer_email', :with => customer.email
            click_button 'Resend unlock instructions'
          end
          
          reset_email = ActionMailer::Base.deliveries.last
          reset_email.to.should eq([customer.email])
          reset_email.from.should eq(["no-reply@credda.com"])
          subject = YAML.load_file("#{Rails.root}/config/locales/devise.en.yml")['en']['devise']['mailer']['unlock_instructions']['subject']
          reset_email.subject.should eq(subject)
        end      
  
        it "redirects to sign in page" do
          within("#customer-unlock") do
            fill_in 'customer_email', :with => customer.email
            click_button 'Resend unlock instructions'
          end
          
          current_path.should eq(new_customer_session_path)
          page.should have_css("#flash-messages")
          message = YAML.load_file("#{Rails.root}/config/locales/devise.en.yml")['en']['devise']['unlocks']['send_instructions']
          page.should have_content(message)          
        end      
      end
  
      describe "with invalid email" do
        it "reloads unlock page" do
          within("#customer-unlock") do
            fill_in 'customer_email', :with => "invalid@email.com"
            click_button 'Resend unlock instructions'
          end
          
          current_path.should eq(customer_unlock_path)
          page.should have_css("#flash-messages")
          message = "not found"
          page.should have_content(message)          
        end      
      end
    end    
  end
  
  context "authenticated" do
    include_context "as authenticated customer"

    it "redirects to customer home" do
      visit new_customer_unlock_path
      current_path.should eq(customer_home_path)
    end
  end
end