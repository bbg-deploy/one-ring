require 'spec_helper'

describe "sign in" do
  context "as anonymous", :anonymous => true do
    include_context "as anonymous"
    let(:customer) { FactoryGirl.create(:customer) }
    before(:each) do
      visit new_customer_session_path
    end

    context "as uncomfirmed" do
      context "with valid credentials" do
        it "reloads sign-in page" do
          within("#new-session") do
            fill_in 'customer_login', :with => customer.email
            fill_in 'customer_password', :with => customer.password
            click_button 'Sign in'
          end
          current_path.should eq(new_customer_session_path)
        end
        it "displays unconfirmed error message" do
          within("#new-session") do
            fill_in 'customer_login', :with => customer.email
            fill_in 'customer_password', :with => customer.password
            click_button 'Sign in'
          end
          page.should have_css("#flash-messages")
          message = YAML.load_file("#{Rails.root}/config/locales/devise.en.yml")['en']['devise']['failure']['unconfirmed']
          page.should have_content(message)
        end
      end
      context "with invalid credentials" do
        before(:each) do
          customer.confirm!
        end
        
        it "reloads sign-in page" do
          within("#new-session") do
            fill_in 'customer_login', :with => customer.email
            fill_in 'customer_password', :with => "incorrect"
            click_button 'Sign in'
          end
          current_path.should eq(new_customer_session_path)
        end
        it "displays unconfirmed error message" do
          within("#new-session") do
            fill_in 'customer_login', :with => customer.email
            fill_in 'customer_password', :with => "incorrect"
            click_button 'Sign in'
          end
          page.should have_css("#flash-messages")
          message = YAML.load_file("#{Rails.root}/config/locales/devise.en.yml")['en']['devise']['failure']['invalid']
          page.should have_content(message)
        end        
      end
    end

    context "as locked" do
      before(:each) do
        customer.confirm!
        customer.lock_access!
      end
      
      context "with valid credentials" do
        it "is locked" do
          customer.access_locked?.should be_true
        end
        it "logs in customer" do
          within("#new-session") do
            fill_in 'customer_login', :with => customer.email
            fill_in 'customer_password', :with => customer.password
            click_button 'Sign in'
          end
          current_path.should_not eq(customer_home_path)
        end      
      end
      context "with invalid credentials" do
        it "reloads sign-in page" do
          within("#new-session") do
            fill_in 'customer_login', :with => customer.email
            fill_in 'customer_password', :with => "incorrect"
            click_button 'Sign in'
          end
          current_path.should eq(new_customer_session_path)
        end
        it "displays unconfirmed error message" do
          within("#new-session") do
            fill_in 'customer_login', :with => customer.email
            fill_in 'customer_password', :with => "incorrect"
            click_button 'Sign in'
          end
          page.should have_css("#flash-messages")
          message = YAML.load_file("#{Rails.root}/config/locales/devise.en.yml")['en']['devise']['failure']['invalid']
          page.should have_content(message)
        end        
      end
    end    
    
    context "as confirmed" do
      before(:each) do
        customer.confirm!
      end
      context "with valid credentials" do
        it "logs in customer with username" do
          within("#new-session") do
            fill_in 'customer_login', :with => customer.username
            fill_in 'customer_password', :with => customer.password
            click_button 'Sign in'
          end
          current_path.should eq(customer_home_path)
        end      

        it "logs in customer with email" do
          within("#new-session") do
            fill_in 'customer_login', :with => customer.email
            fill_in 'customer_password', :with => customer.password
            click_button 'Sign in'
          end
          current_path.should eq(customer_home_path)
        end      
      end
      context "with invalid credentials" do
        it "reloads sign-in page" do
          within("#new-session") do
            fill_in 'customer_login', :with => customer.email
            fill_in 'customer_password', :with => "incorrect"
            click_button 'Sign in'
          end
          current_path.should eq(new_customer_session_path)
        end
        it "displays unconfirmed error message" do
          within("#new-session") do
            fill_in 'customer_login', :with => customer.email
            fill_in 'customer_password', :with => "incorrect"
            click_button 'Sign in'
          end
          page.should have_css("#flash-messages")
          message = YAML.load_file("#{Rails.root}/config/locales/devise.en.yml")['en']['devise']['failure']['invalid']
          page.should have_content(message)
        end
      end      
    end
  end
  
  context "as customer", :authenticated => true do
    include_context "as customer"

    it "redirects to customer home" do
      visit new_customer_session_path
      current_path.should eq(customer_home_path)
    end
  end
end