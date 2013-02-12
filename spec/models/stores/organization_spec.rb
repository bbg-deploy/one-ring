require 'spec_helper'

describe Organization, :organization => true do
  # Model & Factory Validation
  #----------------------------------------------------------------------------
  describe "factory validation", :factory_validation => true do
    specify { Organization.new.should be_an_instance_of(Organization) }

    describe "organization factory" do
      it_behaves_like "valid record", :organization
      
      it "should have stores" do
        organization = FactoryGirl.create(:organization)
        organization.stores.should_not be_empty
      end
    end
  end
  
  # Database
  #----------------------------------------------------------------------------
  describe "database", :database => true do
    # Account Information
    it { should have_db_column(:name) }
    it { should have_db_index(:name) }
    it { should have_db_column(:website) }
    it { should have_db_index(:website) }
  end

  # Associations
  #----------------------------------------------------------------------------
  describe "associations", :associations => true do    
  end
  
  # Attributes
  #----------------------------------------------------------------------------
  describe "attributes", :attributes => true do
    before(:each) do
      attributes = FactoryGirl.build(:organization_attributes_hash)
      organization = Organization.create!(attributes) 
    end

    describe "name" do
      it { should allow_mass_assignment_of(:name) }
      it { should validate_presence_of(:name) }
      it { should validate_uniqueness_of(:name) }
      it { should allow_value("Firestone", "Walmart Co.", "Billy's Tires").for(:name) }
      it { should_not allow_value(nil).for(:name) }

      it "strips leading whitespace" do
        organization = FactoryGirl.create(:organization, :name => " whitespace")
        organization.name.should eq("whitespace")
      end

      it "strips trailing whitespace" do
        organization = FactoryGirl.create(:organization, :name => "whitespace ")
        organization.name.should eq("whitespace")
      end
    end

    describe "website" do
      it { should allow_mass_assignment_of(:website) }
      it { should validate_presence_of(:website) }
      it { should validate_uniqueness_of(:website) }
      it { should allow_value("www.notcredda.com").for(:website) }
      it { should_not allow_value(nil).for(:website) }

      it "strips leading whitespace" do
        organization = FactoryGirl.create(:organization, :website => " www.notcredda.com")
        organization.website.should eq("www.notcredda.com")
      end
      
      it "strips trailing whitespace" do
        organization = FactoryGirl.create(:organization, :website => "www.notcredda.com ")
        organization.website.should eq("www.notcredda.com")
      end
    end
  end
  
  # Behavior
  #----------------------------------------------------------------------------
  describe "behavior", :behavior => true do
  end
end