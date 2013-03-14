require 'spec_helper'

describe Payment do
  # Model & Factory Validation
  #----------------------------------------------------------------------------
  describe "factory validation", :factory_validation => true do
    specify { Payment.new.should be_an_instance_of(Payment) }

    describe "credit factory" do
      it_behaves_like "valid record", :payment
    end

    describe "payment_attributes_hash" do
      it "creates new Payment" do
        attributes = FactoryGirl.build(:payment_attributes_hash)
        payment = Payment.create(attributes)
        payment.should be_valid
      end
    end
  end
  
  # Database
  #----------------------------------------------------------------------------
  describe "database", :database => true do
    it { should have_db_column(:customer_id) }
    it { should have_db_column(:payment_profile_id) }
    it { should have_db_column(:cim_customer_payment_profile_id) }
    it { should have_db_column(:amount) }
  end

  # Associations
  #----------------------------------------------------------------------------
  describe "associations", :associations => true do
    describe "customer" do
      it { should belong_to(:customer) }
      it { should validate_presence_of(:customer) }
      #TODO: This is not working
      #it_behaves_like "immutable belongs_to", :payment, :payment_profile
    end

    describe "payment_profile" do
      it { should belong_to(:payment_profile) }
      it { should validate_presence_of(:payment_profile) }
      #TODO: This is not working
      #it_behaves_like "immutable belongs_to", :payment, :payment_profile
    end
  end

  # Attributes
  #----------------------------------------------------------------------------
  describe "attributes", :attributes => true do
    describe "amount" do
      it { should allow_mass_assignment_of(:amount) }
      it { should validate_presence_of(:amount) }
      it { should allow_value(BigDecimal.new("10")).for(:amount) }
      it { should_not allow_value(nil).for(:amount) }
    end
  end
  
  # State Machine
  #----------------------------------------------------------------------------
  describe "state_machine", :state_machine => true do
  end

  # Behavior
  #----------------------------------------------------------------------------
  describe "behavior", :behavior => true do
  end
end