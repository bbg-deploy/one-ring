require 'spec_helper'

describe Payment do
  # Model & Factory Validation
  #----------------------------------------------------------------------------
  describe "factory validation", :factory_validation => true do
    specify { Payment.new.should be_an_instance_of(Payment) }

    describe "payment factory" do
      it_behaves_like "valid record", :payment
    end
  end
  
  # Associations
  #----------------------------------------------------------------------------
  describe "associations", :associations => true do
    describe "lease" do
      it_behaves_like "required belongs_to", :payment, :lease
      it_behaves_like "immutable belongs_to", :payment, :lease
      it_behaves_like "deletable belongs_to", :payment, :lease
    end
    
    describe "lease_transactions" do
    end
  end
  
  # Attributes
  #----------------------------------------------------------------------------
  describe "attributes", :attributes => true do
    describe "total" do
      it_behaves_like "attr_accessible", :payment, :total,
        [100, 25.50], #Valid values
        [nil, 0, -1, "x"] #Invalid values

      it "rounds up to two decimal places" do
        payment = FactoryGirl.create(:payment, :total => 98.765)
        payment.total.should eq(BigDecimal.new("98.77"))
      end
  
      it "rounds down to two decimal places" do
        payment = FactoryGirl.create(:payment, :total => 98.761)
        payment.total.should eq(BigDecimal.new("98.76"))
      end
    end

    describe "date" do
      it_behaves_like "attr_accessible", :payment, :date,
        [1.day.ago, 3.days.ago, 14.days.from_now], #Valid values
        [nil] #Invalid values
    end

    describe "payment_type" do
      it_behaves_like "attr_accessible", :payment, :payment_type,
        [:credit_card, :echeck, :cash], #Valid values
        [] #Invalid values (Nothing is invalid, since invalid gets set to 'credit_card' by default)
        
      it "is set to 'credit_card' by default" do
        payment = FactoryGirl.create(:payment, :payment_type => nil)
        payment.should be_valid
        payment.payment_type.credit_card?.should be_true
      end
    end
  end
  
  # State Machine
  #----------------------------------------------------------------------------
  describe "state machine", :state_machine => true do
#    it_behaves_like "is_creditable state_machine", :payment
  end

  # Behavior
  #----------------------------------------------------------------------------
  describe "behavior", :behavior => true do
    describe "is_debitable?" do
      it "returns false" do
        payment = FactoryGirl.create(:payment)
        payment.is_debitable?.should be_false
      end
    end

    describe "is_creditable?" do
      it "returns true" do
        payment = FactoryGirl.create(:payment)
        payment.is_creditable?.should be_true
      end
    end

    describe "accounted_amount" do
      context "with no lease_transactions" do
        it "returns accounted_amount == 0.0" do
          payment = FactoryGirl.create(:payment)
          payment.accounted_amount.should eq(BigDecimal.new("0.0"))
        end
      end

      context "with one lease_transactions" do
        it "returns correct accounted_amount" do
          payment = FactoryGirl.create(:payment, :total => BigDecimal.new("55.44"))
          payment.lease_transactions << FactoryGirl.create(:lease_transaction, :lease => payment.lease, :creditable => payment, :amount => BigDecimal.new("14.35"))
          payment.accounted_amount.should eq(BigDecimal.new("14.35"))
        end
      end

      context "with multiple lease_transactions" do
        it "returns correct accounted_amount" do
          payment = FactoryGirl.create(:payment, :total => BigDecimal.new("55.44"))
          payment.lease_transactions << FactoryGirl.create(:lease_transaction, :lease => payment.lease, :creditable => payment, :amount => BigDecimal.new("14.35"))
          payment.lease_transactions << FactoryGirl.create(:lease_transaction, :lease => payment.lease, :creditable => payment, :amount => BigDecimal.new("22.12"))
          payment.accounted_amount.should eq(BigDecimal.new("36.47"))
        end
      end

      context "with too many lease_transactions" do
        it "cannot add additional lease_transactions" do
          payment = FactoryGirl.create(:payment, :total => BigDecimal.new("55.44"))
          payment.lease_transactions << FactoryGirl.create(:lease_transaction, :lease => payment.lease, :creditable => payment, :amount => BigDecimal.new("14.35"))
          expect{ payment.lease_transactions << FactoryGirl.create(:lease_transaction, :lease => payment.lease, :creditable => payment, :amount => BigDecimal.new("52.12")) }.to raise_error
        end
      end
    end

    describe "balance" do
      context "with no lease_transactions" do
        it "returns total" do
          payment = FactoryGirl.create(:payment, :total => BigDecimal.new("89.76"))
          payment.balance.should eq(BigDecimal.new("89.76"))
        end
      end

      context "with one lease_transactions" do
        it "returns correct balance" do
          payment = FactoryGirl.create(:payment, :total => BigDecimal.new("55.44"))
          payment.lease_transactions << FactoryGirl.create(:lease_transaction, :lease => payment.lease, :creditable => payment, :amount => BigDecimal.new("14.35"))
          payment.balance.should eq(BigDecimal.new("41.09"))
        end
      end

      context "with multiple lease_transactions" do
        it "returns correct accounted_amount" do
          payment = FactoryGirl.create(:payment, :total => BigDecimal.new("55.44"))
          payment.lease_transactions << FactoryGirl.create(:lease_transaction, :lease => payment.lease, :creditable => payment, :amount => BigDecimal.new("14.35"))
          payment.lease_transactions << FactoryGirl.create(:lease_transaction, :lease => payment.lease, :creditable => payment, :amount => BigDecimal.new("22.12"))
          payment.balance.should eq(BigDecimal.new("18.97"))
        end
      end
    end

    describe "paid_off?" do
      context "with balance != 0.0" do
        it "returns false" do
          payment = FactoryGirl.create(:payment, :total => BigDecimal.new("55.44"))
          payment.lease_transactions << FactoryGirl.create(:lease_transaction, :lease => payment.lease, :creditable => payment, :amount => BigDecimal.new("14.35"))
          payment.paid_off?.should be_false
        end
      end

      context "with balance == 0.0" do
        it "returns correct accounted_amount" do
          payment = FactoryGirl.create(:payment, :total => BigDecimal.new("55.44"))
          payment.lease_transactions << FactoryGirl.create(:lease_transaction, :lease => payment.lease, :creditable => payment, :amount => BigDecimal.new("14.35"))
          payment.lease_transactions << FactoryGirl.create(:lease_transaction, :lease => payment.lease, :creditable => payment, :amount => BigDecimal.new("41.09"))
          payment.paid_off?.should be_true
        end
      end
    end

    describe "accounts lease transactions" do
      let(:lease) { FactoryGirl.create(:active_lease)}
      
      it "changes lease balance correctly upon save" do
        original_balance = lease.balance
        payment = FactoryGirl.create(:payment, :lease => lease, :total => BigDecimal.new("10.23"))
        lease.reload
        lease.balance.should eq(original_balance + BigDecimal.new("10.23"))
      end
    end
  end
end