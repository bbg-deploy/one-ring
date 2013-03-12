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
    it { should have_db_column(:ledger_id) }
    it { should have_db_column(:cim_payment_profile_id) }
    it { should have_db_column(:type) }
    it { should have_db_column(:amount) }
    it { should have_db_column(:date) }
  end

  # Associations
  #----------------------------------------------------------------------------
  describe "associations", :associations => true do
    describe "ledger" do
      it { should belong_to(:ledger) }
      it { should validate_presence_of(:ledger) }
      it_behaves_like "immutable belongs_to", :credit, :ledger
    end

    describe "entries" do
      it { should have_many(:entries) }
    end
  end

  # Attributes
  #----------------------------------------------------------------------------
  describe "attributes", :attributes => true do
    describe "cim_payment_profile_id" do
      it { should allow_mass_assignment_of(:cim_payment_profile_id) }
      it { should validate_presence_of(:cim_payment_profile_id) }
      it { should allow_value("123343214").for(:cim_payment_profile_id) }
      it { should_not allow_value(nil).for(:cim_payment_profile_id) }
    end

    describe "amount" do
      it { should allow_mass_assignment_of(:amount) }
      it { should validate_presence_of(:amount) }
      it { should allow_value(BigDecimal.new("10")).for(:amount) }
      it { should_not allow_value(nil).for(:amount) }
    end

    describe "type" do
      it { should allow_mass_assignment_of(:type) }
      it { should validate_presence_of(:type) }
      it { should allow_value("CreditCardPayment").for(:type) }
      it { should_not allow_value(nil, "Bank", "CreditCard").for(:type) }
    end

    describe "date" do
      it { should allow_mass_assignment_of(:date) }
      it { should validate_presence_of(:date) }
      it { should allow_value(2.day.ago, 5.days.from_now).for(:date) }
      it { should_not allow_value(nil).for(:date) }
    end
  end
  
  # State Machine
  #----------------------------------------------------------------------------
  describe "state_machine", :state_machine => true do
  end

  # Behavior
  #----------------------------------------------------------------------------
  describe "behavior", :behavior => true do
    describe "accounted_amount" do
      context "with no entries" do
        include_context "with unaccounted credit"

        it "has accounted_amount == 0" do
          credit.accounted_amount.should eq(BigDecimal.new("0"))
        end
      end

      context "with entries < amount" do
        include_context "with partially accounted credit"

        it "has accounted_amount == entries total" do
          credit.accounted_amount.should eq(BigDecimal.new("30"))
        end
      end

      context "with entries == amount" do
        include_context "with fully accounted credit"

        it "has accounted_amount == amount" do
          credit.amount.should eq(BigDecimal.new("100"))
          credit.accounted_amount.should eq(BigDecimal.new("100"))
        end
      end

      context "with entries > amount" do
        include_context "with fully accounted credit"

        it "should raise_error" do
          expect{ entry = FactoryGirl.create(:entry, :credit => credit, :debit => debit, :amount => BigDecimal.new("1")) }.to raise_error
        end
      end
    end

    describe "balance" do
      context "with no entries" do
        include_context "with unaccounted credit"

        it "has balance == amount" do
          credit.balance.should eq(BigDecimal.new("100"))
        end
      end

      context "with entries < amount" do
        include_context "with partially accounted credit"

        it "has balance == (amount - entries total)" do
          credit.balance.should eq(BigDecimal.new("70"))
        end
      end

      context "with entries == amount" do
        include_context "with fully accounted credit"

        it "has balance == 0" do
          credit.balance.should eq(BigDecimal.new("0"))
        end
      end

      context "with entries > amount" do
        include_context "with fully accounted credit"

        it "should raise_error" do
          expect{ entry = FactoryGirl.create(:entry, :credit => credit, :debit => debit, :amount => BigDecimal.new("1")) }.to raise_error
        end
      end
    end

    describe "fully_accounted?" do
      context "with no entries" do
        include_context "with unaccounted credit"

        it "is false" do
          credit.fully_accounted?.should be_false
        end
      end

      context "with entries < amount" do
        include_context "with partially accounted credit"

        it "is false" do
          credit.fully_accounted?.should be_false
        end
      end

      context "with entries == amount" do
        include_context "with fully accounted credit"

        it "is true" do
          credit.fully_accounted?.should be_true
        end
      end
    end
  end
end