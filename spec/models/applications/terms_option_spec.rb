require 'spec_helper'

describe TermsOption do
  # Model & Factory Validation
  #----------------------------------------------------------------------------
  describe "factory validation", :factory_validation => true do
    specify { TermsOption.new.should be_an_instance_of(TermsOption) }

    describe "terms_option factory" do
      it_behaves_like "valid record", :terms_option
    end

    describe "credit_decision_attributes_hash" do
      it "creates new TermsOption" do
        attributes = FactoryGirl.build(:terms_option_attributes_hash)
        terms_option = TermsOption.create(attributes)
        terms_option.should be_valid
      end
    end
  end
  
  # Database
  #----------------------------------------------------------------------------
  describe "database", :database => true do
    it { should have_db_column(:application_id) }
    it { should have_db_column(:markup) }
    it { should have_db_column(:payment_frequency) }
    it { should have_db_column(:number_of_payments) }
    it { should have_db_column(:payment_amount) }
  end

  # Associations
  #----------------------------------------------------------------------------
  describe "associations", :associations => true do
    describe "application" do
      it { should belong_to(:application) }
      it { should validate_presence_of(:application) }
      # TODO: This is broken.  Fix it.
#      it_behaves_like "immutable belongs_to", :credit_decision, :application
    end
  end

  # Attributes
  #----------------------------------------------------------------------------
  describe "attributes", :attributes => true do
    describe "payment_frequency" do
      it { should allow_mass_assignment_of(:payment_frequency) }
      it { should validate_presence_of(:payment_frequency) }
      it { should allow_value("weekly", "biweekly", "semimonthly", "monthly").for(:payment_frequency) }
      it { should_not allow_value(nil, "!", "daily").for(:payment_frequency) }
    end

    describe "markup" do
      it { should allow_mass_assignment_of(:markup) }
      it { should validate_presence_of(:markup) }
      it { should allow_value(BigDecimal.new("1.80"), BigDecimal.new("2.40")).for(:markup) }
      it { should_not allow_value(nil, 2.10, BigDecimal.new("-1.4")).for(:markup) }
    end

    describe "number_of_payments" do
      it { should allow_mass_assignment_of(:number_of_payments) }
      it { should validate_presence_of(:number_of_payments) }
      it { should allow_value(10, 4, 13).for(:number_of_payments) }
      it { should_not allow_value(nil, -1, "a").for(:number_of_payments) }
    end

    describe "payment_amount" do
      it { should allow_mass_assignment_of(:payment_amount) }
      it { should validate_presence_of(:payment_amount) }
      it { should allow_value(BigDecimal.new("180.91"), BigDecimal.new("240.33")).for(:payment_amount) }
      it { should_not allow_value(nil, 210.10, BigDecimal.new("-149")).for(:payment_amount) }
    end
  end

  # Public Methods
  #----------------------------------------------------------------------------
  describe "public_methods", :public_methods => true do
  end
end