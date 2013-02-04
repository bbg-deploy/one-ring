require 'spec_helper'

describe LeaseTransaction do
  # Model & Factory Validation
  #----------------------------------------------------------------------------
  describe "factory validation", :factory_validation => true do
    specify { LeaseTransaction.new.should be_an_instance_of(LeaseTransaction) }

    it_behaves_like "valid record", :lease_transaction
    it_behaves_like "valid record", :lease_transaction_fee
  end

  # Associations
  #----------------------------------------------------------------------------
  describe "associations", :associations => true do
    describe "lease" do
      it_behaves_like "required belongs_to", :lease_transaction, :lease
      it_behaves_like "immutable belongs_to", :lease_transaction, :lease
      it_behaves_like "deletable belongs_to", :lease_transaction, :lease
    end

    describe "debitable" do
      it_behaves_like "immutable polymorphic", :lease_transaction, :debitable
    end

    describe "creditable" do
      it_behaves_like "immutable polymorphic", :lease_transaction, :creditable
    end
  end

  # Attributes
  #----------------------------------------------------------------------------
  describe "attributes", :attributes => true do
    describe "amount" do
      it_behaves_like "attr_accessible", :lease_transaction, :amount,
        [100, 25.50], #Valid values
        [nil, 0, -1, "x"] #Invalid values

      describe "rounding" do
        context "on create" do
          it "rounds up to two decimal places" do
            transaction = FactoryGirl.create(:lease_transaction, :amount => 98.765)
            transaction.amount.should eq(BigDecimal.new("98.77"))
          end
      
          it "rounds down to two decimal places" do
            transaction = FactoryGirl.create(:lease_transaction, :amount => 98.761)
            transaction.amount.should eq(BigDecimal.new("98.76"))
          end
        end
        
        context "on update" do
          it "rounds up to two decimal places" do
            transaction = FactoryGirl.create(:lease_transaction, :amount => 98.76)
            transaction.update_attributes({:amount => 95.765})
            transaction.amount.should eq(BigDecimal.new("95.77"))
          end
      
          it "rounds down to two decimal places" do
            transaction = FactoryGirl.create(:lease_transaction, :amount => 98.76)
            transaction.update_attributes({:amount => 95.761})
            transaction.amount.should eq(BigDecimal.new("95.76"))
          end
        end
      end
    end
  end

  # Behavior
  #----------------------------------------------------------------------------
  describe "behavior", :behavior => true do
    describe "creditable validation" do
      context "with debitable as debit" do
        context "with creditable as debit" do
          it "fails save" do
            lease = FactoryGirl.create(:active_lease)
            lease_transaction = FactoryGirl.build(:lease_transaction, :lease => lease, :amount => BigDecimal.new("25.00"))
            lease_transaction.debitable = FactoryGirl.build(:charge, :lease => lease, :total => BigDecimal.new("-100.00"))
            lease_transaction.creditable = FactoryGirl.build(:charge, :lease => lease, :total => BigDecimal.new("-50.00"))
            expect{ lease_transaction.save! }.to raise_error
          end
        end

        context "with creditable as credit" do
          it "successfully saves" do
            lease = FactoryGirl.create(:active_lease)
            lease_transaction = FactoryGirl.build(:lease_transaction, :lease => lease, :amount => BigDecimal.new("25.00"))
            lease_transaction.debitable = FactoryGirl.build(:charge, :lease => lease, :total => BigDecimal.new("-100.00"))
            lease_transaction.creditable = FactoryGirl.build(:payment, :lease => lease, :total => BigDecimal.new("50.00"))
            expect{ lease_transaction.save! }.to_not raise_error
          end
        end
      end
      
      context "with debitable as credit" do
        context "with creditable as debit" do
          it "fails save" do
            lease = FactoryGirl.create(:active_lease)
            lease_transaction = FactoryGirl.build(:lease_transaction, :lease => lease, :amount => BigDecimal.new("25.00"))
            lease_transaction.debitable = FactoryGirl.build(:payment, :lease => lease, :total => BigDecimal.new("100.00"))
            lease_transaction.creditable = FactoryGirl.build(:charge, :lease => lease, :total => BigDecimal.new("-50.00"))
            expect{ lease_transaction.save! }.to raise_error
          end
        end

        context "with creditable as credit" do
          it "fails save" do
            lease = FactoryGirl.create(:active_lease)
            lease_transaction = FactoryGirl.build(:lease_transaction, :lease => lease, :amount => BigDecimal.new("25.00"))
            lease_transaction.debitable = FactoryGirl.build(:payment, :lease => lease, :total => BigDecimal.new("100.00"))
            lease_transaction.creditable = FactoryGirl.build(:payment, :lease => lease, :total => BigDecimal.new("50.00"))
            expect{ lease_transaction.save! }.to raise_error
          end
        end
      end
    end
    
    describe "validates amount" do
      context "with no other lease_transactions" do
        context "with amount > credit total" do
          it "fails save" do
            lease = FactoryGirl.create(:active_lease)
            lease_transaction = FactoryGirl.build(:lease_transaction, :lease => lease, :amount => BigDecimal.new("55.00"))
            lease_transaction.debitable = FactoryGirl.build(:charge, :lease => lease, :total => BigDecimal.new("-100.00"))
            lease_transaction.creditable = FactoryGirl.build(:payment, :lease => lease, :total => BigDecimal.new("50.00"))
            expect{ lease_transaction.save! }.to raise_error
          end
        end
    
        context "with amount > debit total" do
          it "fails save" do
            lease = FactoryGirl.create(:active_lease)
            lease_transaction = FactoryGirl.build(:lease_transaction, :lease => lease, :amount => BigDecimal.new("105.00"))
            lease_transaction.debitable = FactoryGirl.build(:charge, :lease => lease, :total => BigDecimal.new("-100.00"))
            lease_transaction.creditable = FactoryGirl.build(:payment, :lease => lease, :total => BigDecimal.new("50.00"))
            expect{ lease_transaction.save! }.to raise_error
          end
        end

        context "with amount < debit total, and < credit total" do
          it "saves successfully" do
            lease = FactoryGirl.create(:active_lease)
            lease_transaction = FactoryGirl.build(:lease_transaction, :lease => lease, :amount => BigDecimal.new("45.00"))
            lease_transaction.debitable = FactoryGirl.build(:charge, :lease => lease, :total => BigDecimal.new("-100.00"))
            lease_transaction.creditable = FactoryGirl.build(:payment, :lease => lease, :total => BigDecimal.new("50.00"))
            expect{ lease_transaction.save! }.to_not raise_error
          end
        end
      end

      context "with other lease_transactions" do
        context "with amount > debit balance" do
          it "fails save" do
            debit = FactoryGirl.create(:charge, :total => BigDecimal.new("-100.00"))
            first_payment = FactoryGirl.create(:payment, :total => BigDecimal.new("75.00"))
            transaction = FactoryGirl.create(:lease_transaction, :creditable => first_payment, :debitable => debit, :amount => BigDecimal.new("75.00"))
            credit = FactoryGirl.create(:payment, :total => BigDecimal.new("50.00"))
            amount = BigDecimal.new("45.00")
            debit.reload
            expect{ transaction = FactoryGirl.create(:lease_transaction, :creditable => credit, :debitable => debit, :amount => amount) }.to raise_error
          end
        end
    
        context "with amount > credit balance" do
          it "fails save" do
            debit = FactoryGirl.create(:charge, :total => BigDecimal.new("-100.00"))
            credit = FactoryGirl.create(:payment, :total => BigDecimal.new("50.00"))
            first_charge = FactoryGirl.create(:charge, :total => BigDecimal.new("-25.00"))
            transaction = FactoryGirl.create(:lease_transaction, :creditable => credit, :debitable => first_charge, :amount => BigDecimal.new("25.00"))
            amount = BigDecimal.new("35.00")
            credit.reload
            expect{ transaction = FactoryGirl.create(:lease_transaction, :creditable => credit, :debitable => debit, :amount => amount) }.to raise_error
          end
        end

        context "with amount < debit balance, and < credit balance" do
          it "saves successfully" do
            debit = FactoryGirl.create(:charge, :total => BigDecimal.new("-120.00"))
            first_payment = FactoryGirl.create(:payment, :total => BigDecimal.new("75.00"))
            transaction = FactoryGirl.create(:lease_transaction, :creditable => first_payment, :debitable => debit, :amount => BigDecimal.new("75.00"))
            credit = FactoryGirl.create(:payment, :total => BigDecimal.new("60.00"))
            first_charge = FactoryGirl.create(:charge, :total => BigDecimal.new("-25.00"))
            transaction = FactoryGirl.create(:lease_transaction, :creditable => credit, :debitable => first_charge, :amount => BigDecimal.new("25.00"))
            amount = BigDecimal.new("30.00")
            expect{ transaction = FactoryGirl.create(:lease_transaction, :creditable => credit, :debitable => debit, :amount => amount) }.to_not raise_error
          end
        end
      end
    end

    describe "validates all from the same lease" do
      context "with creditable from a different lease" do
        it "fails save" do
          lease_1 = FactoryGirl.create(:active_lease)
          lease_2 = FactoryGirl.create(:active_lease)
          lease_transaction = FactoryGirl.build(:lease_transaction, :lease => lease_1)
          lease_transaction.creditable.lease = lease_2
          expect{ lease_transaction.save! }.to raise_error
        end
      end

      context "with debitable from a different lease" do
        it "fails save" do
          lease_1 = FactoryGirl.create(:active_lease)
          lease_2 = FactoryGirl.create(:active_lease)
          lease_transaction = FactoryGirl.build(:lease_transaction, :lease => lease_1)
          lease_transaction.debitable.lease = lease_2
          expect{ lease_transaction.save! }.to raise_error
        end
      end

      context "with all from the same lease" do
        it "fails save" do
          lease_1 = FactoryGirl.create(:active_lease)
          debit = FactoryGirl.create(:charge, :lease => lease_1)
          credit = FactoryGirl.create(:payment, :lease => lease_1)
          expect{ transaction = FactoryGirl.create(:lease_transaction, :lease => lease_1, :creditable => credit, :debitable => debit) }.to_not raise_error
        end
      end
    end
  end
end