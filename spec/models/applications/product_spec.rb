require 'spec_helper'

describe Product do
  # Model & Factory Validation
  #----------------------------------------------------------------------------
  describe "factory validation", :factory_validation => true do
    specify { Product.new.should be_an_instance_of(Product) }

    describe "credit factory" do
      it_behaves_like "valid record", :product
    end

    describe "product_attributes_hash" do
      it "creates new Product" do
        attributes = FactoryGirl.build(:product_attributes_hash)
        product = Product.create(attributes)
        product.should be_valid
      end
    end
  end
  
  # Database
  #----------------------------------------------------------------------------
  describe "database", :database => true do
    it { should have_db_column(:application_id) }
    it { should have_db_column(:type) }
    it { should have_db_column(:name) }
    it { should have_db_column(:price) }
    it { should have_db_column(:id_number) }
    it { should have_db_column(:description) }
  end

  # Associations
  #----------------------------------------------------------------------------
  describe "associations", :associations => true do
    describe "application" do
      it { should belong_to(:application) }
      it { should validate_presence_of(:application) }
      # TODO: This is broken.  Fix it.
#      it_behaves_like "immutable belongs_to", :product, :application
    end
  end

  # Attributes
  #----------------------------------------------------------------------------
  describe "attributes", :attributes => true do
    describe "type" do
      it { should allow_mass_assignment_of(:type) }
      it { should validate_presence_of(:type) }
      it { should allow_value("Tire").for(:type) }
      it { should_not allow_value(nil, "Bank", "Jewelry").for(:type) }
    end

    describe "name" do
      it { should allow_mass_assignment_of(:name) }
      it { should validate_presence_of(:name) }
      it { should allow_value("Firestone Winterforce").for(:name) }
      it { should_not allow_value(nil).for(:name) }
    end

    describe "price" do
      it { should allow_mass_assignment_of(:price) }
      it { should validate_presence_of(:price) }
      it { should allow_value(BigDecimal.new("10")).for(:price) }
      it { should_not allow_value(nil, BigDecimal.new("-10")).for(:price) }
    end

    describe "id_number" do
      it { should allow_mass_assignment_of(:id_number) }
      it { should_not validate_presence_of(:id_number) }
      it { should allow_value("TIR1239089", "P90XFJ4595").for(:id_number) }
    end
  end

  # Public Methods
  #----------------------------------------------------------------------------
  describe "public_methods", :public_methods => true do
  end
end