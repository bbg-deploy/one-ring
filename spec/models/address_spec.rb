require 'spec_helper'

describe Address do
  # Model & Factory Validation
  #----------------------------------------------------------------------------
  describe "factory validation", :factory_validation => true do
    specify { Address.new.should be_an_instance_of(Address) }

    it_behaves_like "valid record", :address
  end

  # Associations
  #----------------------------------------------------------------------------
  describe "associations", :associations => true do
    describe "addressable" do
      it_behaves_like "immutable polymorphic", :mailing_address, :addressable
      it_behaves_like "deletable belongs_to", :mailing_address, :addressable
      it_behaves_like "immutable polymorphic", :billing_address, :addressable
      it_behaves_like "deletable belongs_to", :billing_address, :addressable
      it_behaves_like "immutable polymorphic", :store_address, :addressable
      it_behaves_like "deletable belongs_to", :store_address, :addressable
    end    
  end

  # Attributes
  #----------------------------------------------------------------------------
  describe "attributes", :attributes => true do
    describe "address_type" do
      context "as Customer" do
        describe "validates correct address type for addressable Customer" do
          it_behaves_like "attr_accessible", :mailing_address, :address_type,
            [:mailing],  #Valid values
            [:billing, :store] #Invalid values
        end
        
        describe "sets default address type" do
          it "sets to 'mailing' if nil" do
            address = FactoryGirl.create(:mailing_address, :address_type => nil)
            address.address_type.mailing?.should be_true
          end
        end
      end
      
      context "as PaymentProfile" do
        describe "validates correct address type for addressable PaymentProfile" do
          it_behaves_like "attr_accessible", :billing_address, :address_type,
            [:billing],  #Valid values
            [:mailing, :store] #Invalid values
        end
        
        describe "sets default address type" do
          it "sets to 'billing' if nil" do
            address = FactoryGirl.create(:billing_address, :address_type => nil)
            address.address_type.billing?.should be_true
          end
        end
      end

      context "as Store" do
        describe "validates correct address type for addressable Store" do
          it_behaves_like "attr_accessible", :store_address, :address_type,
            [:store],  #Valid values
            [:mailing, :billing] #Invalid values
        end
        
        describe "sets default address type" do
          it "sets to 'store' if nil" do
            address = FactoryGirl.create(:store_address, :address_type => nil)
            address.address_type.store?.should be_true
          end
        end
      end
    end
  
    describe "street" do
      it_behaves_like "attr_accessible", :address, :street,
        ["1600 Pennsylvania Avenue", "4 Elizabeth Road", "123 Temp. St."],  #Valid values
        [nil] #Invalid values
    end
    
    describe "city" do
      it_behaves_like "attr_accessible", :address, :city,
        ["Washington D.C.", "Richmond", "St. Louis"],  #Valid values
        [nil] #Invalid values
    end
    
    describe "state" do
      it_behaves_like "attr_accessible", :address, :state,
        ["Washington", "Virginia", "New Mexico"],  #Valid values
        [nil, "DC", "VA", "Nwe Mexico"] #Invalid values
    end
    
    describe "country" do
      it_behaves_like "attr_accessible", :address, :country,
        ["United States"],  #Valid values
        [nil, "USA", "United States of America"] #Invalid values
    end
  end
    
  # Behavior
  #----------------------------------------------------------------------------
  describe "behavior", :behavior => true do
    describe "geocoding" do
      it "makes a request to Google " do
        address = FactoryGirl.create(:store)
        a_request(:get, /http:\/\/maps.googleapis.com\/maps\/api\/geocode\/json?.*/).should have_been_made.times(2)
      end
  
      subject { FactoryGirl.create(:address) }
        its(:latitude) { should_not be_nil }
        its(:longitude) { should_not be_nil }
        its(:latitude) { should eq(34.934) }
        its(:longitude) { should eq(-81.965) }
    end
  end
end