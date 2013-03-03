require 'spec_helper'

describe ApplicationHelper do
  # Methods
  #----------------------------------------------------------------------------
  describe "user_type" do
    it "returns 'customer' for customers" do
      customer = FactoryGirl.create(:customer)
      assign(:current_customer, customer)
      helper.user_type.should eq("customer")
    end

    it "returns 'store' for stores" do
      store = FactoryGirl.create(:store)
      assign(:current_store, store)
      helper.user_type.should eq("store")
    end

    it "returns 'employee' for employees" do
      employee = FactoryGirl.create(:employee)
      assign(:current_employee, employee)
      helper.user_type.should eq("employee")
    end
  end

  describe "full_title" do
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


  describe "page_id" do
    it "returns correctly when there is a page_id" do
      assign(:page_id, "payment_profile")
      helper.page_id.should =~ /payment_profile/
    end

    it "returns correctly when there is no page_id" do
      assign(:page_id, nil)
      helper.page_id.should =~ /test/
    end    
  end


  describe "navbar_classes" do
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
end