require 'spec_helper'

describe Debit do
  # Model & Factory Validation
  #----------------------------------------------------------------------------
  describe "factory validation", :factory_validation => true do
    specify { Debit.new.should be_an_instance_of(Debit) }

    describe "debit factory" do
      it_behaves_like "valid record", :debit
    end

    describe "debit_attributes_hash" do
      it "creates new Debit" do
        attributes = FactoryGirl.build(:debit_attributes_hash)
        debit = Debit.create(attributes)
        debit.should be_valid
      end
    end
  end
  
  # Database
  #----------------------------------------------------------------------------
  describe "database", :database => true do
    it { should have_db_column(:ledger_id) }
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
      it_behaves_like "immutable belongs_to", :debit, :ledger
    end

    describe "entries" do
      it { should have_many(:entries) }
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

    describe "type" do
      it { should allow_mass_assignment_of(:type) }
      it { should validate_presence_of(:type) }
      it { should allow_value("Fee").for(:type) }
      it { should_not allow_value(nil, "Bank", "CreditCardPayment").for(:type) }
    end

    describe "date" do
      it { should allow_mass_assignment_of(:date) }
      it { should validate_presence_of(:date) }
      it { should allow_value(2.day.ago, 5.days.from_now).for(:date) }
      it { should_not allow_value(nil).for(:date) }
    end

    describe "due_date" do
      it { should allow_mass_assignment_of(:due_date) }
      it { should validate_presence_of(:due_date) }
      it { should allow_value(2.day.ago, 5.days.from_now).for(:due_date) }
      it { should_not allow_value(nil).for(:due_date) }
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
        include_context "with unaccounted debit"
        
        it "has accounted_amount == 0" do
          debit.accounted_amount.should eq(BigDecimal.new("0"))
        end
      end

      context "with entries < amount" do
        include_context "with partially accounted debit"

        it "has accounted_amount == entries total" do
          debit.accounted_amount.should eq(BigDecimal.new("30"))
        end
      end

      context "with entries < amount" do
        include_context "with fully accounted debit"

        it "has accounted_amount == entries total" do
          debit.accounted_amount.should eq(BigDecimal.new("100"))
        end
      end

      context "with entries > amount" do
        include_context "with fully accounted debit"

        it "should raise_error" do
          expect{ entry = FactoryGirl.create(:entry, :debit => debit, :amount => BigDecimal.new("1")) }.to raise_error
        end
      end
    end

    describe "balance" do
      context "with no entries" do
        include_context "with unaccounted debit"

        it "has balance == amount" do
          debit.balance.should eq(BigDecimal.new("100"))
        end
      end

      context "with entries < amount" do
        include_context "with partially accounted debit"

        it "has balance == (amount - entries total)" do
          debit.balance.should eq(BigDecimal.new("70"))
        end
      end

      context "with entries < amount" do
        include_context "with fully accounted debit"

        it "has balance == (amount - entries total)" do
          debit.balance.should eq(BigDecimal.new("0"))
        end
      end

      context "with entries > amount" do
        include_context "with fully accounted debit"

        it "should raise_error" do
          expect{ entry = FactoryGirl.create(:entry, :debit => debit, :amount => BigDecimal.new("1")) }.to raise_error
        end
      end
    end

    describe "fully_accounted?" do
      context "with no entries" do
        include_context "with unaccounted debit"

        it "is false" do
          debit.fully_accounted?.should be_false
        end
      end

      context "with entries < amount" do
        include_context "with partially accounted debit"

        it "is false" do
          debit.fully_accounted?.should be_false
        end
      end

      context "with entries == amount" do
        include_context "with fully accounted debit"

        it "is true" do
          debit.fully_accounted?.should be_true
        end
      end
    end

    describe "paid_off?" do
      context "with no entries" do
        include_context "with unaccounted debit"

        it "is false" do
          debit.paid_off?.should be_false
        end
      end

      context "with entries < amount" do
        include_context "with partially accounted debit"

        it "is false" do
          debit.paid_off?.should be_false
        end
      end

      context "with entries == amount" do
        include_context "with fully accounted debit"

        it "is true" do
          debit.paid_off?.should be_true
        end
      end
    end
  end
end