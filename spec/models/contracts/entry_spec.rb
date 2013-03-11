require 'spec_helper'

describe Entry do
  # Model & Factory Validation
  #----------------------------------------------------------------------------
  describe "factory validation", :factory_validation => true do
    specify { Entry.new.should be_an_instance_of(Entry) }

    it_behaves_like "valid record", :entry
    it_behaves_like "valid record", :entry
  end

  # Database
  #----------------------------------------------------------------------------
  describe "database", :database => true do
    it { should have_db_column(:ledger_id) }
    it { should have_db_column(:credit_id) }
    it { should have_db_column(:debit_id) }
    it { should have_db_column(:amount) }
  end

  # Associations
  #----------------------------------------------------------------------------
  describe "associations", :associations => true do
    describe "ledger" do
      it { should belong_to(:ledger) }
      it { should validate_presence_of(:ledger) }
      it_behaves_like "immutable belongs_to", :entry, :ledger
    end

    describe "debit" do
      it { should belong_to(:debit) }
      it { should validate_presence_of(:debit) }
      it_behaves_like "immutable belongs_to", :entry, :debit
    end

    describe "credit" do
      it { should belong_to(:credit) }
      it { should validate_presence_of(:credit) }
      it_behaves_like "immutable belongs_to", :entry, :credit
    end
  end

  # Attributes
  #----------------------------------------------------------------------------
  describe "attributes", :attributes => true do
    describe "amount" do
      it { should allow_mass_assignment_of(:amount) }
      it { should validate_presence_of(:amount) }
      it { should allow_value(BigDecimal.new("10"), 100, 25.50).for(:amount) }
      it { should_not allow_value(nil, -1, BigDecimal.new("-15"), "x").for(:amount) }

      describe "rounding" do
        context "on create" do
          it "rounds up to two decimal places" do
            entry = FactoryGirl.create(:entry, :amount => 98.765)
            entry.amount.should eq(BigDecimal.new("98.77"))
          end
      
          it "rounds down to two decimal places" do
            entry = FactoryGirl.create(:entry, :amount => 98.761)
            entry.amount.should eq(BigDecimal.new("98.76"))
          end
        end
        
        context "on update" do
          it "rounds up to two decimal places" do
            entry = FactoryGirl.create(:entry, :amount => 98.76)
            entry.update_attributes({:amount => 95.765})
            entry.amount.should eq(BigDecimal.new("95.77"))
          end
      
          it "rounds down to two decimal places" do
            entry = FactoryGirl.create(:entry, :amount => 98.76)
            entry.update_attributes({:amount => 95.761})
            entry.amount.should eq(BigDecimal.new("95.76"))
          end
        end
      end
    end
  end

  # Behavior
  #----------------------------------------------------------------------------
  describe "behavior", :behavior => true do
    describe "validates amount" do
      let(:ledger) { FactoryGirl.create(:ledger) }

      context "with amount > credit amount" do
        it "fails save" do
          credit = FactoryGirl.build(:credit, :ledger => ledger, :amount => BigDecimal.new("50"))
          debit = FactoryGirl.build(:debit, :ledger => ledger, :amount => BigDecimal.new("100"))
          entry = FactoryGirl.build(:entry, :credit => credit, :debit => debit, :amount => BigDecimal.new("51"))
          expect{ entry.save! }.to raise_error
        end
      end
    
      context "with amount > debit amount" do
        it "fails save" do
          credit = FactoryGirl.build(:credit, :ledger => ledger, :amount => BigDecimal.new("150"))
          debit = FactoryGirl.build(:debit, :ledger => ledger, :amount => BigDecimal.new("50"))
          entry = FactoryGirl.build(:entry, :credit => credit, :debit => debit, :amount => BigDecimal.new("51"))
          expect{ entry.save! }.to raise_error
        end
      end

      context "with amount < credit amount and debit amount" do
        it "fails save" do
          credit = FactoryGirl.build(:credit, :ledger => ledger, :amount => BigDecimal.new("100"))
          debit = FactoryGirl.build(:debit, :ledger => ledger, :amount => BigDecimal.new("100"))
          entry = FactoryGirl.build(:entry, :credit => credit, :debit => debit, :amount => BigDecimal.new("51"))
          expect{ entry.save! }.to_not raise_error
        end
      end
    end

    describe "validates all from the same ledger" do
      let(:ledger) { FactoryGirl.create(:ledger) }
      context "with creditable from a different lease" do
        it "fails save" do
          debit = FactoryGirl.create(:debit, :ledger => ledger)
          credit = FactoryGirl.create(:credit)
          expect{ Entry.create!({:ledger => ledger, :credit => credit, :debit => debit, :amount => BigDecimal.new("10")} ) }.to raise_error
        end
      end

      context "with debitable from a different lease" do
        it "fails save" do
          debit = FactoryGirl.create(:debit)
          credit = FactoryGirl.create(:credit, :ledger => ledger)
          expect{ Entry.create!({:ledger => ledger, :credit => credit, :debit => debit, :amount => BigDecimal.new("10")} ) }.to raise_error
        end
      end

      context "with all from the same lease" do
        it "saves successfully" do
          debit = FactoryGirl.create(:debit, :ledger => ledger)
          credit = FactoryGirl.create(:credit, :ledger => ledger)
          expect{ Entry.create!({:ledger => ledger, :credit => credit, :debit => debit, :amount => BigDecimal.new("10")} ) }.to_not raise_error
        end
      end
    end
  end
end