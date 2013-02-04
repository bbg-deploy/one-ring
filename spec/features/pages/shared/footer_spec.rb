require 'spec_helper'

describe "Footer" do
  before(:each) do
    visit home_path
  end
  context "anonymous" do
    include_context "as anonymous visitor"
    it "has header" do
      page.should have_css("footer")      
    end
    describe "footer links" do
      describe "Home" do
        it "has link" do
          page.has_link?("Home").should be_true
        end
        it "goes to home_path" do
          page.click_link("Home")
          current_path.should eq(home_path)
        end
      end
      describe "Investor Relations" do
        it "has link" do
          href = "http://www.creddafinancial.com"
          page.should have_selector "a[href='#{href}']", text: "Investor Relations"
        end
      end
    end
    describe "copyright" do
      it "has our copyright" do
        page.should have_content("Copyright Credda Financial 2011-2012")
      end
    end
  end
  context "authenticated" do
    include_context "as authenticated customer"
  end
end