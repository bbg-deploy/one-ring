require 'spec_helper'
require 'cancan'
require 'cancan/matchers'
include CustomerAttributeContexts

describe Admin::CustomersController do
  context "as anonymous", :anonymous => true do
    include_context "as anonymous"

    specify { subject.current_admin.should be_nil }
    describe "#index", :index => true do
      it_should_behave_like "#index denied"
    end    
    describe "#new", :new => true do
      it_should_behave_like "#new denied"
    end
    describe "#create", :create => true do
      context "with valid create attributes" do
        it_should_behave_like "#create denied" do
          include_context "#create customer with valid attributes"
        end
      end
      context "with invalid attributes" do
        it_should_behave_like "#create denied" do
          include_context "#create customer with invalid attributes"
        end
      end
    end
    describe "#show", :show => true do
      context "with valid object" do
        it_should_behave_like "#show denied" do
          include_context "#show valid customer"
        end        
      end
      context "with invalid object" do
        it_should_behave_like "#show routing error" do
          include_context "#show invalid customer"
        end
      end
    end
    describe "#edit", :edit => true do
      context "with valid object" do
        it_should_behave_like "#edit denied" do
          include_context "#edit valid customer"
        end        
      end
      context "with invalid object" do
        it_should_behave_like "#edit routing error" do
          include_context "#edit invalid customer"
        end
      end
    end    
    describe "#update", :update => true do
      context "with valid attributes" do
        it_should_behave_like "#update denied" do
          include_context "#update customer with valid attributes"
        end
      end
      context "with invalid attributes" do
        it_should_behave_like "#update denied" do
          include_context "#update customer with invalid attributes"
        end
      end
    end
    describe "#delete", :delete => true do
      context "with valid object" do
        it_should_behave_like "#delete denied" do
          include_context "#delete valid customer"
        end
      end
      context "with invalid object" do
      it_should_behave_like "#delete routing error" do
        include_context "#delete invalid customer"
      end
      end
    end
  end

  context "as admin", :admin => true do
    include_context "as admin"

    specify { subject.current_admin.should_not be_nil }
    describe "#index", :index => true do
      it_should_behave_like "#index allowed"
    end    
    describe "#new", :new => true do
      it_should_behave_like "#new allowed"
    end
    describe "#create", :create => true do
      context "with valid attributes" do
        it_should_behave_like "#create valid" do
          include_context "#create customer with valid attributes"
        end
      end
      context "with invalid attributes" do
        it_should_behave_like "#create invalid" do
          include_context "#create customer with invalid attributes"
        end
        it_should_behave_like "#create invalid" do
          include_context "#create customer without mailing address"
        end
        it_should_behave_like "#create invalid" do
          include_context "#create customer without billing address"
        end
        it_should_behave_like "#create invalid" do
          include_context "#create customer without phone number"
        end
      end
    end

    describe "#show", :show => true do
      context "with valid object" do
        it_should_behave_like "#show valid" do
          include_context "#show valid customer"
        end
      end
      context "with invalid object" do
        it_should_behave_like "#show routing error" do
          include_context "#show invalid customer"
        end        
      end
    end
    describe "#edit", :edit => true do
      context "with valid object" do
        it_should_behave_like "#edit valid" do
          include_context "#edit valid customer"
        end
      end
      context "with invalid object" do
        it_should_behave_like "#edit routing error" do
          include_context "#edit invalid customer"
        end        
      end
    end
    describe "#update", :udpate => true do
      context "with valid attributes" do
        it_should_behave_like "#update valid" do
          include_context "#update customer with valid attributes"
        end
      end
      context "with invalid attributes" do
        it_should_behave_like "#update invalid" do
          include_context "#update customer with invalid attributes"
        end
      end
#TODO: Debug these specs!!
=begin
      context "without email confirmation", :failing => true do
        it_should_behave_like "#update invalid" do
          include_context "#update customer email without confirmation"
        end
      end
      context "without password confirmation", :failing => true do
        it_should_behave_like "#update invalid" do
          include_context "#update customer password without confirmation"
        end
      end
=end
    end
    describe "#delete", :delete => true do
      context "with valid object" do
        it_should_behave_like "#delete valid" do
          include_context "#delete valid customer"
        end
      end
      context "with invalid object" do
        it_should_behave_like "#delete routing error" do
          include_context "#delete invalid customer"
        end
      end
    end
  end
end