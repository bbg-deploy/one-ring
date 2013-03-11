require 'spec_helper'

describe Ledger do
  # Model & Factory Validation
  #----------------------------------------------------------------------------
  describe "factory validation", :factory_validation => true do
    specify { Ledger.new.should be_an_instance_of(Ledger) }

    describe "installment factory" do
      it_behaves_like "valid record", :ledger      
    end

    describe "ledger_attributes_hash" do
      it "creates new Ledger" do
        attributes = FactoryGirl.build(:ledger_attributes_hash)
        ledger = Ledger.create(attributes)
        ledger.should be_valid
      end
    end
  end
  
  # Database
  #----------------------------------------------------------------------------
  describe "database", :database => true do
    it { should have_db_column(:contract_id) }
    it { should have_db_index(:contract_id) }
    it { should have_db_column(:type) }
  end

  # Associations
  #----------------------------------------------------------------------------
  describe "associations", :associations => true do
    describe "credits" do
      it { should have_many(:credits) }
    end

    describe "debits" do
      it { should have_many(:debits) }
    end

    describe "entries" do
      it { should have_many(:entries) }
    end
  end

  # Attributes
  #----------------------------------------------------------------------------
  describe "attributes", :attributes => true do
    describe "contract_id" do
      it { should allow_mass_assignment_of(:contract) }
      it { should validate_presence_of(:contract) }
      it { should allow_value(FactoryGirl.create(:contract)).for(:contract) }
      it { should_not allow_value(nil,).for(:contract) }
    end

    describe "type" do
      it { should allow_mass_assignment_of(:type) }
      it { should validate_presence_of(:type) }
      it { should allow_value("FifoLedger").for(:type) }
      it { should_not allow_value(nil, "lease_2_own", "Ledger").for(:type) }
    end
  end
  
  # State Machine
  #----------------------------------------------------------------------------
  describe "state_machine", :state_machine => true do
  end

  # Behavior
  #----------------------------------------------------------------------------
  describe "behavior", :behavior => true do
    describe "total_owed" do
      include_context "with accounted ledger"

      it "returns correct remaining balance" do
        ledger.total_owed.should eq(BigDecimal.new("160"))
      end
    end

    describe "total_paid" do
      include_context "with accounted ledger"

      it "returns correct remaining balance" do
        ledger.total_paid.should eq(BigDecimal.new("130"))
      end
    end

    describe "total_accounted" do
      context "before accounting" do
        include_context "with unaccounted ledger"

        it "returns 0" do
          ledger.total_accounted.should eq(BigDecimal.new("0"))
        end
      end

      context "after accounting" do
        include_context "with accounted ledger"

        context "with more debits than credits" do
          it "returns accounted amount" do
            ledger.total_accounted.should eq(BigDecimal.new("130"))
          end
        end

        context "with more credits than debits" do
          before(:each) do
            add_credit(2.days.ago, BigDecimal.new("100"))
            ledger.do_accounting!
          end

          it "returns accounted amount" do
            ledger.total_accounted.should eq(BigDecimal.new("160"))
          end
        end
      end
    end

    describe "percentage_paid" do
      include_context "with accounted ledger"

      it "returns correct remaining balance" do
        ledger.percentage_paid.should eq(BigDecimal.new("81.25"))
      end
    end

    describe "ordered_credits" do
      context "with naturally ordered credits" do
        let(:ledger) { FactoryGirl.create(:ledger) }
        let(:credit_1) { FactoryGirl.create(:credit, :ledger => ledger, :date => 5.days.ago) }
        let(:credit_2) { FactoryGirl.create(:credit, :ledger => ledger, :date => 3.days.ago) }
        let(:credit_3) { FactoryGirl.create(:credit, :ledger => ledger, :date => 1.day.ago) }

        it "returns ordered by date ascending" do
          ledger.ordered_credits.should eq([credit_1.becomes(CreddaCredit), credit_2.becomes(CreddaCredit), credit_3.becomes(CreddaCredit)])
        end
      end

      context "with naturally unordered credits" do
        let(:ledger) { FactoryGirl.create(:ledger) }
        let(:credit_1) { FactoryGirl.create(:credit, :ledger => ledger, :date => 3.days.ago) }
        let(:credit_2) { FactoryGirl.create(:credit, :ledger => ledger, :date => 1.days.ago) }
        let(:credit_3) { FactoryGirl.create(:credit, :ledger => ledger, :date => 5.day.ago) }

        it "returns ordered by date ascending" do
          ledger.ordered_credits.should eq([credit_3.becomes(CreddaCredit), credit_1.becomes(CreddaCredit), credit_2.becomes(CreddaCredit)])
        end
      end
    end
    
    describe "ordered_debits" do
      context "with naturally ordered debits" do
        let(:ledger) { FactoryGirl.create(:ledger) }
        let(:debit_1) { FactoryGirl.create(:debit, :ledger => ledger, :date => 5.days.ago) }
        let(:debit_2) { FactoryGirl.create(:debit, :ledger => ledger, :date => 3.days.ago) }
        let(:debit_3) { FactoryGirl.create(:debit, :ledger => ledger, :date => 1.day.ago) }

        it "returns ordered by date ascending" do
          ledger.ordered_debits.should eq([debit_1.becomes(Fee), debit_2.becomes(Fee), debit_3.becomes(Fee)])
        end
      end

      context "with naturally unordered credits" do
        let(:ledger) { FactoryGirl.create(:ledger) }
        let(:debit_1) { FactoryGirl.create(:debit, :ledger => ledger, :date => 3.days.ago) }
        let(:debit_2) { FactoryGirl.create(:debit, :ledger => ledger, :date => 1.days.ago) }
        let(:debit_3) { FactoryGirl.create(:debit, :ledger => ledger, :date => 5.day.ago) }

        it "returns ordered by date ascending" do
          ledger.ordered_debits.should eq([debit_3.becomes(Fee), debit_1.becomes(Fee), debit_2.becomes(Fee)])
        end
      end
    end

    describe "credits_date_array" do
      it "is pending"
    end

    describe "do_accounting!" do
      context "with no existing entries" do
        include_context "with unaccounted ledger"

        before(:each) do
          ledger.do_accounting!
        end

        it "should create entries" do
          ledger.entries.should_not be_empty
        end

        it "should mark debit_1 as paid_off" do
          debit_1.paid_off?.should be_true
        end

        it "should mark debit_2 as paid_off" do
          debit_2.reload
          debit_2.paid_off?.should be_true
        end

        it "should have remaining balance of 40 in debit_3" do
          debit_3.paid_off?.should be_false
          debit_3.balance.should eq(BigDecimal.new("30"))
        end
      end

      context "with invalid accounting" do
        include_context "with invalid accounted ledger"
 
        it "should delete earlier entries" do
          initial_id = ledger.entries.first.id
          ledger.do_accounting!
          ledger.entries.first.id.should_not eq(initial_id)
        end
      end

      context "with valid accounting" do
        include_context "with accounted ledger"
 
        it "should not affect entries if re-accounted" do
          original_entries = ledger.entries
          ledger.do_accounting!
          ledger.entries.should eq(original_entries)
        end
      end
    end

    describe "valid_accounting?" do
      include_context "with accounted ledger"

      context "after do_accounting!" do        
        it "should return true" do
          ledger.valid_accounting?.should be_true
        end
      end

      context "without first entry" do
        before(:each) do
          delete_first_entry
        end
        
        it "should return false" do
          ledger.valid_accounting?.should be_false
        end        
      end
    end
    
    describe "validate_accounting!" do
      context "with valid accounting" do
        include_context "with accounted ledger"
        
      end

      context "with invalid accounting" do
        include_context "with invalid accounted ledger"        
        
      end
    end
  end

  # Private Methods
  #----------------------------------------------------------------------------
  describe "private_methods", :private_methods => true do
    describe "max_entry_amount" do
      context "with larger debit than credit" do
        let(:ledger) { FactoryGirl.create(:ledger) }
        let(:debit) { FactoryGirl.create(:debit, :amount => BigDecimal.new("20")) }
        let(:credit) { FactoryGirl.create(:credit, :amount => BigDecimal.new("14")) }
  
        it "returns lowest balance" do
          ledger.send(:max_entry_amount, credit, debit).should eq(BigDecimal.new("14"))
        end
      end

      context "with larger credit than debit" do
        let(:ledger) { FactoryGirl.create(:ledger) }
        let(:debit) { FactoryGirl.create(:debit, :amount => BigDecimal.new("20")) }
        let(:credit) { FactoryGirl.create(:credit, :amount => BigDecimal.new("21")) }
  
        it "returns lowest balance" do
          ledger.send(:max_entry_amount, credit, debit).should eq(BigDecimal.new("20"))
        end
      end
    end
  end
end