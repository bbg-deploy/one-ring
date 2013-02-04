require 'spec_helper'

describe Layouts::ApplicationHelper do
  describe "#full_title" do
    it "returns title when there is a page_title" do
      assign(:page_title, "Test Page Title")
      helper.full_title.should eq("Credda | Test Page Title")
    end

    it "returns title when there is no page_title" do
      assign(:title, nil)
      helper.full_title.should eq("Credda")
    end
  end

  describe "#full_description" do
    it "returns description when there is a page_description" do
      assign(:page_description, "Test Description")
      helper.full_description.should eq("Test Description")
    end

    it "returns description when there is no page_description" do
      assign(:page_description, nil)
      helper.full_description.should eq("Credda provides innovating innovative lease-to-own financing solutions")
    end
  end

  describe "#body_classes" do
    describe "user classes" do
      context "as anonymous user" do
        specify { helper.body_classes.should =~ /anon/ }
      end
      context "as admin" do
        it "assigns admin class" do
          assign(:current_user, FactoryGirl.create(:admin))
          helper.body_classes.should =~ /admin/
        end
      end
      context "as agent" do
        it "assigns agent class" do
          assign(:current_user, FactoryGirl.create(:agent))
          helper.body_classes.should =~ /agent/
        end
      end
      context "as store" do
        it "assigns store class" do
          assign(:current_user, FactoryGirl.create(:store))
          helper.body_classes.should =~ /store/
        end
      end
      context "as customer" do
        it "assigns customer class" do
          assign(:current_user, FactoryGirl.create(:customer))
          helper.body_classes.should =~ /customer/
        end
      end
    end
    describe "device classes" do
      it "assigns mobile class" do
        assign(:mobile_device, true)
        helper.body_classes.should =~ /mobile/
      end

      it "assigns full class" do
        assign(:mobile_device, false)
        helper.body_classes.should =~ /full/
      end
    end
    describe "controller classes" do
      it "assigns controller class" do
        helper.body_classes.should =~ /test/
      end
    end
  end
  describe "#navbar_classes" do
    describe "style classes" do
      specify { helper.navbar_classes.should =~ /navbar-inverse/ }
    end
    describe "device classes" do
      it "assigns mobile class" do
        assign(:mobile_device, true)
        helper.navbar_classes.should =~ /navbar-fixed-top/
      end

      it "assigns full class" do
        assign(:mobile_device, false)
        helper.navbar_classes.should =~ /navbar-fixed-top/
      end
    end
  end
  describe "#main_div_id" do
    it "returns div_id when there is a page_id" do
      assign(:page_id, "test_id")
      helper.main_div_id.should eq("test_id")
    end

    it "returns div_id when there is no page_id" do
      assign(:page_id, nil)
      helper.main_div_id.should eq("default")
    end    
  end
end
=begin 
  def main_div_id(page_id = nil)
    page_id.nil? ? "defaut" : page_id 
  end
=end