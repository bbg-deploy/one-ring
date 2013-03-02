require 'spec_helper'

describe Address do
  # Model & Factory Validation
  #----------------------------------------------------------------------------
  describe "factory validation", :factory_validation => true do
    specify { Address.new.should be_an_instance_of(Address) }

    describe "address factory" do
      it_behaves_like "valid record", :address    
    end

    describe "mailing_address factory" do
      it_behaves_like "valid record", :mailing_address    
    end

    describe "billing_address factory" do
      it_behaves_like "valid record", :billing_address    
    end

    describe "store_address factory" do
      it_behaves_like "valid record", :store_address    
    end

    describe "invalid_address factory" do
      it_behaves_like "invalid record", :invalid_address    
    end

    describe "address_attributes_hash factory" do
      it "creates new address when passed to Address" do
        attributes = FactoryGirl.build(:address_attributes_hash)
        address = Address.create(attributes)
        address.should be_valid
      end
    end
  end

  # Database
  #----------------------------------------------------------------------------
  describe "database", :database => true do
    it { should have_db_column(:addressable_id) }
    it { should have_db_column(:addressable_type) }
    it { should have_db_column(:address_type) }
    it { should have_db_column(:street) }
    it { should have_db_column(:city) }
    it { should have_db_column(:state) }
    it { should have_db_column(:zip_code) }
    it { should have_db_column(:country) }
    it { should have_db_column(:latitude) }
    it { should have_db_column(:longitude) }
  end

  # Associations
  #----------------------------------------------------------------------------
  describe "associations", :associations => true do
    describe "addressable" do
      it { should belong_to(:addressable) }
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
      it { should allow_mass_assignment_of(:address_type) }
      it { should validate_presence_of(:address_type) }
      it { should allow_value("mailing", "billing", "store").for(:address_type) }
      it { should_not allow_value(nil, "!", "special").for(:address_type) }
 
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
      it { should allow_mass_assignment_of(:street) }
      it { should validate_presence_of(:street) }
      it { should allow_value("1600 Pennsylvania Avenue", "4 Elizabeth Road", "123 Temp. St.").for(:street) }
      it { should_not allow_value(nil).for(:street) }
    end
    
    describe "city" do
      it { should allow_mass_assignment_of(:city) }
      it { should validate_presence_of(:city) }
      it { should allow_value("Washington D.C.", "Richmond", "St. Louis").for(:city) }
      it { should_not allow_value(nil).for(:city) }
    end
    
    describe "state" do
      it { should allow_mass_assignment_of(:state) }
      it { should validate_presence_of(:state) }
      it { should allow_value("Washington", "Virginia", "New Mexico").for(:state) }
      it { should_not allow_value(nil, "VA", "MA").for(:state) }
    end
    
    describe "zip_code" do
      it { should allow_mass_assignment_of(:zip_code) }
      it { should validate_presence_of(:zip_code) }
      it { should allow_value("20165", "11111", "98765").for(:zip_code) }
      it { should_not allow_value(nil, "201651", "11111-1234").for(:zip_code) }
    end

    describe "country" do
      it { should allow_mass_assignment_of(:country) }
      it { should validate_presence_of(:country) }
      it { should allow_value("United States").for(:country) }
      it { should_not allow_value(nil, "USA", "United States of America").for(:country) }
    end
  end
    
  # Behavior
  #----------------------------------------------------------------------------
  describe "behavior", :behavior => true do
    describe "geocoding" do
      it "makes a request to Google " do
        address = FactoryGirl.create(:address)
        a_request(:get, /http:\/\/maps.googleapis.com\/maps\/api\/geocode\/json?.*/).should have_been_made.times(3)
      end
  
      subject { FactoryGirl.create(:address) }
        its(:latitude) { should_not be_nil }
        its(:longitude) { should_not be_nil }
        its(:latitude) { should eq(34.934) }
        its(:longitude) { should eq(-81.965) }
    end
  end
end