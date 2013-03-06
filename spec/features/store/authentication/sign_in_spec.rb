require 'spec_helper'

describe "sign in" do
  context "as anonymous", :anonymous => true do
    include_context "as anonymous"
    let(:store) { FactoryGirl.create(:store) }
    before(:each) do
      visit new_store_session_path
    end

    context "as uncomfirmed" do
      context "with valid credentials" do
        it "reloads sign-in page" do
          within("#new-session") do
            fill_in 'store_login', :with => store.email
            fill_in 'store_password', :with => store.password
            click_button 'Sign in'
          end
          current_path.should eq(new_store_session_path)
        end
        it "displays unconfirmed error message" do
          within("#new-session") do
            fill_in 'store_login', :with => store.email
            fill_in 'store_password', :with => store.password
            click_button 'Sign in'
          end
          page.should have_css("#flash-messages")
          message = YAML.load_file("#{Rails.root}/config/locales/devise.en.yml")['en']['devise']['failure']['unconfirmed']
          page.should have_content(message)
        end
      end
      context "with invalid credentials" do
        before(:each) do
          store.confirm!
        end
        
        it "reloads sign-in page" do
          within("#new-session") do
            fill_in 'store_login', :with => store.email
            fill_in 'store_password', :with => "incorrect"
            click_button 'Sign in'
          end
          current_path.should eq(new_store_session_path)
        end
        it "displays unconfirmed error message" do
          within("#new-session") do
            fill_in 'store_login', :with => store.email
            fill_in 'store_password', :with => "incorrect"
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
        store.confirm!
        store.lock_access!
      end
      
      context "with valid credentials" do
        it "is locked" do
          store.access_locked?.should be_true
        end
        it "logs in customer" do
          within("#new-session") do
            fill_in 'store_login', :with => store.email
            fill_in 'store_password', :with => store.password
            click_button 'Sign in'
          end
          current_path.should_not eq(store_home_path)
        end      
      end
      context "with invalid credentials" do
        it "reloads sign-in page" do
          within("#new-session") do
            fill_in 'store_login', :with => store.email
            fill_in 'store_password', :with => "incorrect"
            click_button 'Sign in'
          end
          current_path.should eq(new_store_session_path)
        end
        it "displays unconfirmed error message" do
          within("#new-session") do
            fill_in 'store_login', :with => store.email
            fill_in 'store_password', :with => "incorrect"
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
        store.confirm!
      end
      context "with valid credentials" do
        it "logs in store with username" do
          within("#new-session") do
            fill_in 'store_login', :with => store.username
            fill_in 'store_password', :with => store.password
            click_button 'Sign in'
          end
          current_path.should eq(store_home_path)
        end

        it "logs in store with email" do
          within("#new-session") do
            fill_in 'store_login', :with => store.email
            fill_in 'store_password', :with => store.password
            click_button 'Sign in'
          end
          current_path.should eq(store_home_path)
        end
      end
      context "with invalid credentials" do
        it "reloads sign-in page" do
          within("#new-session") do
            fill_in 'store_login', :with => store.email
            fill_in 'store_password', :with => "incorrect"
            click_button 'Sign in'
          end
          current_path.should eq(new_store_session_path)
        end
        it "displays unconfirmed error message" do
          within("#new-session") do
            fill_in 'store_login', :with => store.email
            fill_in 'store_password', :with => "incorrect"
            click_button 'Sign in'
          end
          page.should have_css("#flash-messages")
          message = YAML.load_file("#{Rails.root}/config/locales/devise.en.yml")['en']['devise']['failure']['invalid']
          page.should have_content(message)
        end
      end
    end
  end
  
  context "as store", :authenticated => true do
    include_context "as store"

    it "redirects to store home" do
      visit new_store_session_path
      current_path.should eq(store_home_path)
    end
  end
end