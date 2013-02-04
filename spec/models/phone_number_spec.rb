require 'spec_helper'

describe PhoneNumber do
  # Model & Factory Validation
  #----------------------------------------------------------------------------
  describe "factory validation", :factory_validation => true do
    specify { PhoneNumber.new.should be_an_instance_of(PhoneNumber) }

    it_behaves_like "valid record", :phone_number
  end

  # Associations
  #----------------------------------------------------------------------------
  describe "associations", :associations => true do
    describe "phonable" do
      it_behaves_like "immutable polymorphic", :customer_phone_number, :phonable
      it_behaves_like "deletable belongs_to", :customer_phone_number, :phonable
      it_behaves_like "immutable polymorphic", :store_phone_number, :phonable
      it_behaves_like "deletable belongs_to", :store_phone_number, :phonable
    end
  end

  # Attributes
  #----------------------------------------------------------------------------
  describe "attributes", :attributes => true do
    describe "phone_number_type" do
      context "as Customer" do
        it_behaves_like "attr_accessible", :customer_phone_number, :phone_number_type,
          [:customer],  #Valid values
          [:store] #Invalid values

        describe "sets default phone_number type" do
          it "sets to 'customer' if nil" do
            phone_number = FactoryGirl.create(:customer_phone_number, :phone_number_type => nil)
            phone_number.phone_number_type.customer?.should be_true
            phone_number.reload
            phone_number.phone_number_type.customer?.should be_true
          end
        end
      end
      
      context "as Store" do
        it_behaves_like "attr_accessible", :store_phone_number, :phone_number_type,
          [:store],  #Valid values
          [:customer] #Invalid values

        describe "sets default phone_number type" do
          it "sets to 'store' if nil" do
            phone_number = FactoryGirl.create(:store_phone_number, :phone_number_type => nil)
            phone_number.phone_number_type.store?.should be_true
            phone_number.reload
            phone_number.phone_number_type.store?.should be_true
          end
        end
      end
    end

    describe "phone_number" do
      it_behaves_like "attr_accessible", :phone_number, :phone_number,
        ["703-444-1234", "7034301245"],  #Valid values
        [nil, "703-303-111", "703-987-11223", "703450432", "70343012345"] #Invalid values
    end
  
    describe "primary" do
      it_behaves_like "attr_accessible", :phone_number, :primary,
        ["1", "0"],  #Valid values
        [nil] #Invalid values
    end
  
    describe "cell_phone" do
      it_behaves_like "attr_accessible", :phone_number, :cell_phone,
        ["1", "0"],  #Valid values
        [nil] #Invalid values
    end
  end

  # Behavior
  #----------------------------------------------------------------------------
  describe "behavior", :behavior => true do
  end
end