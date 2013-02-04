require 'spec_helper'

describe "Header" do
  before(:each) do
    visit home_path
  end

  context "anonymous" do
    include_context "as anonymous visitor"

    it "has header" do
      page.should have_css("header")      
    end

    describe "logo" do
      it "has logo" do
        within("header") do
          page.should have_css("#logo")
          page.click_on("logo")
          current_path.should eq(home_path)
        end
      end
    end
    
    describe "navigation links" do
      it "has 'For Business' link" do
        within("header") do
          page.has_link?("For Business").should be_true
          page.click_link("For Business")
          current_path.should eq(for_business_path)
        end
      end

      it "has 'How It Works' link" do
        within("header") do
          page.has_link?("How It Works").should be_true
          page.click_link("How It Works")
          current_path.should eq(learn_more_path)
        end
      end

      it "has 'About' link" do
        within("header") do
          page.has_link?("About").should be_true
          page.click_link("About")
          current_path.should eq(about_path)
        end
      end
    end

    describe "navigation buttons" do
      it "has 'Sign In' button" do
        within("header") do
          page.has_link?("Sign in").should be_true
          page.click_link("Sign in")
          current_path.should eq(new_customer_session_path)
        end
      end
    end
  end
  context "authenticated" do
    include_context "as authenticated customer"
  end
end