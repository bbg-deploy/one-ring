require 'spec_helper'

describe "home page" do
  context "anonymous" do
    include_context "as anonymous visitor"
    before(:each) do
      visit home_path
    end

    describe "page elements" do
      it "has proper title" do
        page.should have_content "Flexible Financing Today"
      end
      it "has a header" do
        page.should have_css "header"        
      end
      it "has a footer" do
        page.should have_css "footer"        
      end
      it "has proper links" do
        page.has_link?("Learn More").should be_true
        page.has_link?("Sign Up").should be_true
      end
    end
    
    describe "link functionality" do
      it "goes to learn_more_path from 'Learn More'" do
        page.click_on("Learn More")
        current_path.should eq(learn_more_path)
      end

      it "goes to new_registration_path from 'Sign Up'" do
        page.click_on("Sign Up")
        current_path.should eq(new_customer_registration_path)
      end
    end
  end
  context "authenticated" do
    include_context "as authenticated customer"

    describe "Home page" do
      before(:each) do
        visit home_path
      end
      it "has proper title" do
#        page.should have_content "Flexible Financing Today"
      end
    end
  end
end