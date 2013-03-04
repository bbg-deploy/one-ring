require 'spec_helper'

describe PhoneNumber do
  # Model & Factory Validation
  #----------------------------------------------------------------------------
  describe "factory validation", :factory_validation => true do
    specify { PhoneNumber.new.should be_an_instance_of(PhoneNumber) }

    describe "phone_number factory" do
      it_behaves_like "valid record", :phone_number
    end

    describe "store_phone_number factory" do
      it_behaves_like "valid record", :store_phone_number
    end

    describe "invalid_phone_number factory" do
      it_behaves_like "invalid record", :invalid_phone_number
    end

    describe "phone_number_attributes_hash" do
      it "creates new phone_number when passed to PhoneNumber" do
        attributes = FactoryGirl.build(:phone_number_attributes_hash)
        phone_number = PhoneNumber.create(attributes)
        phone_number.should be_valid
      end
    end
  end

  # Database
  #----------------------------------------------------------------------------
  describe "database", :database => true do
    it { should have_db_column(:phonable_id) }
    it { should have_db_column(:phonable_type) }
    it { should have_db_column(:phone_number) }
    it { should have_db_column(:primary) }
    it { should have_db_column(:cell_phone) }
  end

  # Associations
  #----------------------------------------------------------------------------
  describe "associations", :associations => true do
    describe "phonable" do
      it { should belong_to(:phonable) }
      it_behaves_like "immutable polymorphic", :customer_phone_number, :phonable
      it_behaves_like "deletable belongs_to", :customer_phone_number, :phonable
      it_behaves_like "immutable polymorphic", :store_phone_number, :phonable
      it_behaves_like "deletable belongs_to", :store_phone_number, :phonable
    end
  end

  # Attributes
  #----------------------------------------------------------------------------
  describe "attributes", :attributes => true do
    describe "phone_number" do
      it { should allow_mass_assignment_of(:phone_number) }
      it { should validate_presence_of(:phone_number) }
      it { should allow_value("703-309-1874", "7033091874").for(:phone_number) }
      it { should_not allow_value(nil, "703-303-111", "703-987-11223", "703450432", "70343012345").for(:phone_number) }
    end

    describe "primary" do
      it { should allow_mass_assignment_of(:primary) }
      it { should allow_value(true, false).for(:primary) }
      it { should_not allow_value(nil, "!").for(:primary) }
    end

    describe "cell_phone" do
      it { should allow_mass_assignment_of(:cell_phone) }
      it { should allow_value(true, false).for(:cell_phone) }
      it { should_not allow_value(nil, "!").for(:cell_phone) }
    end  
  end

  # Behavior
  #----------------------------------------------------------------------------
  describe "behavior", :behavior => true do
  end
end