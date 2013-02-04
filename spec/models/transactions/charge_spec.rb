require 'spec_helper'

describe Charge do
  # Model & Factory Validation
  #----------------------------------------------------------------------------
  describe "factory validation", :factory_validation => true do
    specify { Charge.new.should be_an_instance_of(Charge) }

    describe "charge factory" do
      it_behaves_like "valid record", :charge
      
      it "has lease" do
        charge = FactoryGirl.create(:charge)
        charge.lease.should_not be_nil
      end
    end

    describe "charge_with_lease_transactions factory" do
      it_behaves_like "valid record", :charge_with_lease_transactions
      
      it "has lease transactions" do
        charge = FactoryGirl.create(:charge_with_lease_transactions)
        charge.lease_transactions.should_not be_nil
      end
    end
  end
  
  # Associations
  #----------------------------------------------------------------------------
  describe "associations", :associations => true do
    describe "lease" do
      it_behaves_like "required belongs_to", :charge, :lease
      it_behaves_like "immutable belongs_to", :charge, :lease
      it_behaves_like "deletable belongs_to", :charge, :lease
    end
    
    describe "lease_transactions" do
    end
  end

  # Attributes
  #----------------------------------------------------------------------------
  describe "attributes", :attributes => true do
    describe "total" do
      it_behaves_like "attr_accessible", :charge, :total,
        [BigDecimal.new("-100"), -100, BigDecimal.new("-25.50"), -44.36], #Valid values
        [nil, BigDecimal.new("0"), BigDecimal.new("1"), "x"] #Invalid values

      describe "rounding" do
        context "on create" do
          it "rounds up to two decimal places" do
            charge = FactoryGirl.create(:charge, :total => BigDecimal.new("-98.765"))
            charge.total.should eq(BigDecimal.new("-98.77"))
          end
      
          it "rounds down to two decimal places" do
            charge = FactoryGirl.create(:charge, :total => BigDecimal.new("-98.761"))
            charge.total.should eq(BigDecimal.new("-98.76"))
          end
        end
        
        context "on update" do
          it "rounds up to two decimal places" do
            charge = FactoryGirl.create(:charge, :total => BigDecimal.new("-98.76"))
            charge.update_attributes({:total => BigDecimal.new("-95.765")})
            charge.total.should eq(BigDecimal.new("-95.77"))
          end
      
          it "rounds down to two decimal places" do
            charge = FactoryGirl.create(:charge, :total => BigDecimal.new("-98.76"))
            charge.update_attributes({:total => BigDecimal.new("-95.761")})
            charge.total.should eq(BigDecimal.new("-95.76"))
          end
        end
      end
    end

    describe "issue_date" do
      it_behaves_like "attr_accessible", :charge, :issue_date,
        [1.day.ago, 3.days.ago, 14.days.from_now], #Valid values
        [nil] #Invalid values
    end

    describe "due_date" do
      it_behaves_like "attr_accessible", :charge, :due_date,
        [1.day.ago, 3.days.ago, 14.days.from_now], #Valid values
        [nil] #Invalid values
    end
  end
  
  # State Machine
  #----------------------------------------------------------------------------
  describe "state_machine", :state_machine => true do
    #TODO: Write actual tests for lateness state machine
#    it_behaves_like "is_lateable state_machine", :charge
  end

  # Behavior
  #----------------------------------------------------------------------------
  describe "behavior", :behavior => true do
    describe "is_debitable?" do
      it "returns true" do
        charge = FactoryGirl.create(:charge)
        charge.is_debitable?.should be_true
      end
    end

    describe "is_creditable?" do
      it "returns false" do
        charge = FactoryGirl.create(:charge)
        charge.is_creditable?.should be_false
      end
    end
    
    describe "accounted_amount" do
      context "with no lease_transactions" do
        it "returns accounted_amount == 0.0" do
          charge = FactoryGirl.create(:charge)
          charge.accounted_amount.should eq(BigDecimal.new("0.0"))
        end
      end

      context "with one lease_transactions" do
        it "returns correct accounted_amount" do
          charge = FactoryGirl.create(:charge, :total => BigDecimal.new("-55.44"))
          charge.lease_transactions << FactoryGirl.create(:lease_transaction, :debitable => charge, :amount => BigDecimal.new("14.35"))
          charge.accounted_amount.should eq(BigDecimal.new("14.35"))
        end
      end

      context "with multiple lease_transactions" do
        it "returns correct accounted_amount" do
          charge = FactoryGirl.create(:charge, :total => BigDecimal.new("-55.44"))
          charge.lease_transactions << FactoryGirl.create(:lease_transaction, :debitable => charge, :amount => BigDecimal.new("14.35"))
          charge.lease_transactions << FactoryGirl.create(:lease_transaction, :debitable => charge, :amount => BigDecimal.new("22.12"))
          charge.accounted_amount.should eq(BigDecimal.new("36.47"))
        end
      end

      context "with too many lease_transactions" do
        it "cannot add beyond balance" do
          charge = FactoryGirl.create(:charge, :total => BigDecimal.new("-55.44"))
          charge.lease_transactions << FactoryGirl.create(:lease_transaction, :debitable => charge, :amount => BigDecimal.new("14.35"))
          expect{ charge.lease_transactions << FactoryGirl.create(:lease_transaction, :debitable => charge, :amount => BigDecimal.new("52.12")) }.to raise_error
        end
      end
    end

    describe "balance" do
      context "with no lease_transactions" do
        it "returns total" do
          charge = FactoryGirl.create(:charge, :total => BigDecimal.new("-89.76"))
          charge.balance.should eq(BigDecimal.new("-89.76"))
        end
      end

      context "with one lease_transactions" do
        it "returns correct balance" do
          charge = FactoryGirl.create(:charge, :total => BigDecimal.new("-55.44"))
          charge.lease_transactions << FactoryGirl.create(:lease_transaction, :debitable => charge, :amount => BigDecimal.new("14.35"))
          charge.balance.should eq(BigDecimal.new("-41.09"))
        end
      end

      context "with multiple lease_transactions" do
        it "returns correct accounted_amount" do
          charge = FactoryGirl.create(:charge, :total => BigDecimal.new("-55.44"))
          charge.lease_transactions << FactoryGirl.create(:lease_transaction, :debitable => charge, :amount => BigDecimal.new("14.35"))
          charge.lease_transactions << FactoryGirl.create(:lease_transaction, :debitable => charge, :amount => BigDecimal.new("22.12"))
          charge.balance.should eq(BigDecimal.new("-18.97"))
        end
      end
    end

    describe "validates balance" do
      context "with balance < 0" do
        it "saves successfully" do
          charge = FactoryGirl.create(:charge, :total => BigDecimal.new("-55.44"))
          charge.lease_transactions << FactoryGirl.create(:lease_transaction, :lease => charge.lease, :debitable => charge, :amount => BigDecimal.new("14.35"))
          charge.lease_transactions << FactoryGirl.create(:lease_transaction, :lease => charge.lease, :debitable => charge, :amount => BigDecimal.new("22.12"))
          expect{ charge.save! }.to_not raise_error
        end
      end

      context "with balance == 0" do
        it "saves successfully" do
          charge = FactoryGirl.create(:charge, :total => BigDecimal.new("-55.44"))
          charge.lease_transactions << FactoryGirl.create(:lease_transaction, :lease => charge.lease, :debitable => charge, :amount => BigDecimal.new("40.35"))
          charge.lease_transactions << FactoryGirl.create(:lease_transaction, :lease => charge.lease, :debitable => charge, :amount => BigDecimal.new("15.09"))
          expect{ charge.save! }.to_not raise_error
        end
      end

      context "with balance > 0" do
        it "cannot add lease_transactions" do
          charge = FactoryGirl.create(:charge, :total => BigDecimal.new("-55.44"))
          charge.lease_transactions << FactoryGirl.create(:lease_transaction, :lease => charge.lease, :debitable => charge, :amount => BigDecimal.new("40.35"))
          expect{ charge.lease_transactions << FactoryGirl.create(:lease_transaction, :lease => charge.lease, :debitable => charge, :amount => BigDecimal.new("15.10")) }.to raise_error
        end
      end
    end

    describe "paid_off?" do
      context "with balance != 0.0" do
        it "returns false" do
          charge = FactoryGirl.create(:charge, :total => BigDecimal.new("-55.44"))
          charge.lease_transactions << FactoryGirl.create(:lease_transaction, :debitable => charge, :amount => BigDecimal.new("14.35"))
          charge.paid_off?.should be_false
        end
      end

      context "with balance == 0.0" do
        it "returns correct accounted_amount" do
          charge = FactoryGirl.create(:charge, :total => BigDecimal.new("-55.44"))
          charge.lease_transactions << FactoryGirl.create(:lease_transaction, :debitable => charge, :amount => BigDecimal.new("14.35"))
          charge.lease_transactions << FactoryGirl.create(:lease_transaction, :debitable => charge, :amount => BigDecimal.new("41.09"))
          charge.paid_off?.should be_true
        end
      end
    end

    describe "accounts lease transactions" do
      it "changes lease balance correctly upon save" do
        lease = FactoryGirl.create(:active_lease)
        original_balance = lease.balance
        charge = FactoryGirl.create(:charge, :lease => lease, :total => BigDecimal.new("-10.55"))
        lease.reload
        lease.balance.should eq(original_balance + BigDecimal.new("-10.55"))
      end
    end
  end
end