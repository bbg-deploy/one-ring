require 'spec_helper'

describe "unlock account" do
  context "as anonymous", :anonymous => true do
    include_context "as anonymous"
    let(:customer) { FactoryGirl.create(:customer) }
    before(:each) do
      visit new_customer_unlock_path
    end
    
    context "unlocked" do
      before(:each) do
        customer.unlock_access!
        reset_email
      end
      describe "with valid attributes" do
        it "reloads unlock page" do
          within("#unlock") do
            fill_in 'customer_email', :with => customer.email
            click_button 'Send Unlock Instructions'
          end
          
          # App Behavior
          current_path.should eq(customer_unlock_path)
          page.should have_css("#flash-messages")
          message = YAML.load_file("#{Rails.root}/config/locales/devise.en.yml")['en']['errors']['messages']['not_locked']
          page.should have_content(message)
        end      

        it "does not send email" do
          within("#unlock") do
            fill_in 'customer_email', :with => customer.email
            click_button 'Send Unlock Instructions'
          end
          
          last_email.should be_nil
        end      
      end
  
      describe "with invalid email" do
        it "reloads unlock page" do
          within("#unlock") do
            fill_in 'customer_email', :with => "invalid@email.com"
            click_button 'Send Unlock Instructions'
          end
          
          current_path.should eq(customer_unlock_path)
          page.should have_css("#flash-messages")
          message = "not found"
          page.should have_content(message)          
        end      

        it "does not send email" do
          within("#unlock") do
            fill_in 'customer_email', :with => customer.email
            click_button 'Send Unlock Instructions'
          end
          
          last_email.should be_nil
        end      
      end
    end
    
    context "locked" do
      before(:each) do
        customer.lock_access!
        reset_email
      end

      describe "with valid attributes" do
        it "redirects to sign in page" do
          within("#unlock") do
            fill_in 'customer_email', :with => customer.email
            click_button 'Send Unlock Instructions'
          end
          
          current_path.should eq(new_customer_session_path)
          page.should have_css("#flash-messages")
          message = YAML.load_file("#{Rails.root}/config/locales/devise.en.yml")['en']['devise']['unlocks']['send_instructions']
          page.should have_content(message)          
        end      

        it "sends unlock reset email" do
          within("#unlock") do
            fill_in 'customer_email', :with => customer.email
            click_button 'Send Unlock Instructions'
          end
          
          last_email.to.should eq([customer.email])
          last_email.from.should eq(["no-reply@credda.com"])
          subject = YAML.load_file("#{Rails.root}/config/locales/devise.en.yml")['en']['devise']['mailer']['unlock_instructions']['subject']
          last_email.subject.should eq(subject)
        end      
      end
  
      describe "with invalid email" do
        it "reloads unlock page" do
          within("#unlock") do
            fill_in 'customer_email', :with => "invalid@email.com"
            click_button 'Send Unlock Instructions'
          end
          
          current_path.should eq(customer_unlock_path)
          page.should have_css("#flash-messages")
          message = "not found"
          page.should have_content(message)          
        end      


        it "does not send email" do
          within("#unlock") do
            fill_in 'customer_email', :with => "invalid@email.com"
            click_button 'Send Unlock Instructions'
          end
          
          last_email.should be_nil
        end      
      end
    end    
  end
  
  context "as customer" do
    include_context "as customer"

    it "redirects to customer home" do
      visit new_customer_unlock_path
      current_path.should eq(customer_home_path)
    end
  end
end