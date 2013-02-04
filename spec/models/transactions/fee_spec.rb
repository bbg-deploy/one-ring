require 'spec_helper'

describe Fee do
  # Model & Factory Validation
  #----------------------------------------------------------------------------
  describe "factory validation", :factory_validation => true do
    specify { Fee.new.should be_an_instance_of(Fee) }

    describe "fee factory" do
      it_behaves_like "valid record", :fee
      
      it "has lease" do
        charge = FactoryGirl.create(:fee)
        charge.lease.should_not be_nil
      end
    end

    describe "fee_with_lease_transactions factory" do
      it_behaves_like "valid record", :fee_with_lease_transactions
      
      it "has lease transactions" do
        charge = FactoryGirl.create(:fee_with_lease_transactions)
        charge.lease_transactions.should_not be_nil
      end
    end
  end
  
  # Associations
  #----------------------------------------------------------------------------
  describe "associations", :associations => true do
    describe "lease" do  
      it_behaves_like "required belongs_to", :fee, :lease
      it_behaves_like "immutable belongs_to", :fee, :lease
      it_behaves_like "deletable belongs_to", :fee, :lease
    end
    
    describe "least_transactions", :failing => true do
    end
  end

  # Attributes
  #----------------------------------------------------------------------------
  describe "attributes", :attributes => true do
    describe "total" do
      it_behaves_like "attr_accessible", :fee, :total,
        [BigDecimal.new("-100"), -100, BigDecimal.new("-25.50"), -44.36], #Valid values
        [nil, BigDecimal.new("0"), BigDecimal.new("1"), "x"] #Invalid values

      describe "rounding" do
        context "on create" do
          it "rounds up to two decimal places" do
            fee = FactoryGirl.create(:fee, :total => BigDecimal.new("-98.765"))
            fee.total.should eq(BigDecimal.new("-98.77"))
          end
      
          it "rounds down to two decimal places" do
            fee = FactoryGirl.create(:fee, :total => BigDecimal.new("-98.761"))
            fee.total.should eq(BigDecimal.new("-98.76"))
          end
        end
        
        context "on update" do
          it "rounds up to two decimal places" do
            fee = FactoryGirl.create(:fee, :total => BigDecimal.new("-98.76"))
            fee.update_attributes({:total => BigDecimal.new("-95.765")})
            fee.total.should eq(BigDecimal.new("-95.77"))
          end
      
          it "rounds down to two decimal places" do
            fee = FactoryGirl.create(:fee, :total => BigDecimal.new("-98.76"))
            fee.update_attributes({:total => BigDecimal.new("-95.761")})
            fee.total.should eq(BigDecimal.new("-95.76"))
          end
        end
      end
    end

    describe "issue_date" do
      it_behaves_like "attr_accessible", :fee, :issue_date,
        [1.day.ago, 3.days.ago, 14.days.from_now], #Valid values
        [nil] #Invalid values
    end
  end
  
  # Behavior
  #----------------------------------------------------------------------------
  describe "behavior", :behavior => true do
    describe "is_debitable?" do
      it "returns true" do
        fee = FactoryGirl.create(:fee)
        fee.is_debitable?.should be_true
      end
    end

    describe "is_creditable?" do
      it "returns false" do
        fee = FactoryGirl.create(:fee)
        fee.is_creditable?.should be_false
      end
    end

    describe "accounted_amount" do
      context "with no lease_transactions" do
        it "returns accounted_amount == 0.0" do
          fee = FactoryGirl.create(:fee)
          fee.accounted_amount.should eq(BigDecimal.new("0.0"))
        end
      end

      context "with one lease_transactions" do
        it "returns correct accounted_amount" do
          fee = FactoryGirl.create(:fee, :total => BigDecimal.new("-55.44"))
          fee.lease_transactions << FactoryGirl.create(:lease_transaction, :lease => fee.lease, :debitable => fee, :amount => BigDecimal.new("14.35"))
          fee.accounted_amount.should eq(BigDecimal.new("14.35"))
        end
      end

      context "with multiple lease_transactions" do
        it "returns correct accounted_amount" do
          fee = FactoryGirl.create(:fee, :total => BigDecimal.new("-55.44"))
          fee.lease_transactions << FactoryGirl.create(:lease_transaction, :lease => fee.lease, :debitable => fee, :amount => BigDecimal.new("14.35"))
          fee.lease_transactions << FactoryGirl.create(:lease_transaction, :lease => fee.lease, :debitable => fee, :amount => BigDecimal.new("22.12"))
          fee.accounted_amount.should eq(BigDecimal.new("36.47"))
        end
      end

      context "with too many lease_transactions" do
        it "cannot add new lease_transactions" do
          fee = FactoryGirl.create(:fee, :total => BigDecimal.new("-55.44"))
          fee.lease_transactions << FactoryGirl.create(:lease_transaction, :lease => fee.lease, :debitable => fee, :amount => BigDecimal.new("14.35"))
          expect{ fee.lease_transactions << FactoryGirl.create(:lease_transaction, :lease => fee.lease, :debitable => fee, :amount => BigDecimal.new("52.12")) }.to raise_error
        end
      end
    end

    describe "balance" do
      context "with no lease_transactions" do
        it "returns total" do
          fee = FactoryGirl.create(:fee, :total => BigDecimal.new("-89.76"))
          fee.balance.should eq(BigDecimal.new("-89.76"))
        end
      end

      context "with one lease_transactions" do
        it "returns correct balance" do
          fee = FactoryGirl.create(:fee, :total => BigDecimal.new("-55.44"))
          fee.lease_transactions << FactoryGirl.create(:lease_transaction, :lease => fee.lease, :debitable => fee, :amount => BigDecimal.new("14.35"))
          fee.balance.should eq(BigDecimal.new("-41.09"))
        end
      end

      context "with multiple lease_transactions" do
        it "returns correct accounted_amount" do
          fee = FactoryGirl.create(:fee, :total => BigDecimal.new("-55.44"))
          fee.lease_transactions << FactoryGirl.create(:lease_transaction, :lease => fee.lease, :debitable => fee, :amount => BigDecimal.new("14.35"))
          fee.lease_transactions << FactoryGirl.create(:lease_transaction, :lease => fee.lease, :debitable => fee, :amount => BigDecimal.new("22.12"))
          fee.balance.should eq(BigDecimal.new("-18.97"))
        end
      end
    end

    describe "validates balance" do
      context "with balance < 0" do
        it "saves successfully" do
          fee = FactoryGirl.create(:fee, :total => BigDecimal.new("-55.44"))
          fee.lease_transactions << FactoryGirl.create(:lease_transaction, :lease => fee.lease, :debitable => fee, :amount => BigDecimal.new("14.35"))
          fee.lease_transactions << FactoryGirl.create(:lease_transaction, :lease => fee.lease, :debitable => fee, :amount => BigDecimal.new("22.12"))
          expect{ fee.save! }.to_not raise_error
        end
      end

      context "with balance == 0" do
        it "saves successfully" do
          fee = FactoryGirl.create(:fee, :total => BigDecimal.new("-55.44"))
          fee.lease_transactions << FactoryGirl.create(:lease_transaction, :lease => fee.lease, :debitable => fee, :amount => BigDecimal.new("40.35"))
          fee.lease_transactions << FactoryGirl.create(:lease_transaction, :lease => fee.lease, :debitable => fee, :amount => BigDecimal.new("15.09"))
          expect{ fee.save! }.to_not raise_error
        end
      end

      context "with balance > 0" do
        it "cannot add additional lease_transactions" do
          fee = FactoryGirl.create(:fee, :total => BigDecimal.new("-55.44"))
          fee.lease_transactions << FactoryGirl.create(:lease_transaction, :lease => fee.lease, :debitable => fee, :amount => BigDecimal.new("40.35"))
          expect{ fee.lease_transactions << FactoryGirl.create(:lease_transaction, :lease => fee.lease, :debitable => fee, :amount => BigDecimal.new("15.10")) }.to raise_error
        end
      end
    end

    describe "paid_off?" do
      context "with balance != 0.0" do
        it "returns false" do
          fee = FactoryGirl.create(:fee, :total => BigDecimal.new("-55.44"))
          fee.lease_transactions << FactoryGirl.create(:lease_transaction, :lease => fee.lease, :debitable => fee, :amount => BigDecimal.new("14.35"))
          fee.paid_off?.should be_false
        end
      end

      context "with balance == 0.0" do
        it "returns correct accounted_amount" do
          fee = FactoryGirl.create(:charge, :total => BigDecimal.new("-55.44"))
          fee.lease_transactions << FactoryGirl.create(:lease_transaction, :lease => fee.lease, :debitable => fee, :amount => BigDecimal.new("14.35"))
          fee.lease_transactions << FactoryGirl.create(:lease_transaction, :lease => fee.lease, :debitable => fee, :amount => BigDecimal.new("41.09"))
          fee.paid_off?.should be_true
        end
      end
    end

    describe "accounts lease transactions" do
      it "changes lease balance correctly upon save" do
        lease = FactoryGirl.create(:claimed_lease)
        original_balance = lease.balance
        fee = FactoryGirl.create(:fee, :lease => lease, :total => BigDecimal.new("-5.20"))
        lease.reload
        lease.balance.should eq(original_balance + BigDecimal.new("-5.20"))
      end
    end
  end
end