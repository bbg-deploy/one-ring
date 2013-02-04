require 'spec_helper'

describe "pages" do
  context "anonymous" do
    include_context "as anonymous visitor"

    describe "Home page" do
      before(:each) do
        visit home_path
      end
      it "has proper title" do
        page.should have_content "Flexible Financing Today"
      end
      it "has proper links" do
        page.has_link?("Learn More").should be_true
        page.has_link?("Sign Up").should be_true
      end
    end
    describe "How It Works page" do
      before(:each) do
        visit learn_more_path
      end
      it "has proper title" do
        page.should have_content "Learn More"
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