require 'spec_helper'

describe Lease do
  # Model & Factory Validation
  #----------------------------------------------------------------------------
  describe "factory validation", :factory_validation => true do
    specify { Lease.new.should be_an_instance_of(Lease) }

    describe "lease factory" do
      let(:lease) {FactoryGirl.create(:lease)}

      it_behaves_like "valid record", :lease
      
      it "has a customer" do
        lease.customer.should_not be_nil
      end

      it "is active" do
        lease.active?.should be_true
      end
    end

    describe "active_lease factory" do
      let(:lease) {FactoryGirl.create(:active_lease)}

      it_behaves_like "valid record", :active_lease  

      it "is active" do
        lease.active?.should be_true
      end

      it "has charges" do
        lease.charges.should_not be_empty
      end
    end

    describe "charged_off_lease factory" do
      let(:lease) {FactoryGirl.create(:charged_off_lease)}

      it_behaves_like "valid record", :charged_off_lease  

      it "is charged_off" do
        lease.charged_off?.should be_true
      end
    end

    describe "completed_lease factory" do
      let(:lease) {FactoryGirl.create(:completed_lease)}

      it_behaves_like "valid record", :completed_lease  

      it "is completed" do
        lease.completed?.should be_true
      end
    end
  end

  # Associations
  #----------------------------------------------------------------------------
  describe "associations", :associations => true do
    describe "customer" do
      it_behaves_like "deletable belongs_to", :lease, :customer
    end
  
    describe "store" do
      it_behaves_like "deletable belongs_to", :lease, :store
    end    

    describe "lease_application" do
      it_behaves_like "required belongs_to", :lease, :lease_application
      it_behaves_like "immutable belongs_to", :lease, :lease_application
      it_behaves_like "deletable belongs_to", :lease, :lease_application
    end    
  end

  # State Machine
  #----------------------------------------------------------------------------
  describe "state machine", :state_machine => true do
    describe "initial conditions" do
      it "defaults to 'active'" do
        lease = FactoryGirl.create(:lease)
        lease.active?.should be_true
      end
    end

    describe "events", :events => true do
      describe "charge_off" do
        context "as 'active'" do
         let(:lease) { FactoryGirl.create(:active_lease) }

          it "transitions to 'charged_off'" do
            lease.active?.should be_true
            lease.charge_off
            lease.charged_off?.should be_true
          end
        end

        context "as 'charged_off'" do
          let(:lease) { FactoryGirl.create(:charged_off_lease) }

          it "remains 'charged_off'" do
            lease.charged_off?.should be_true
            lease.charge_off
            lease.charged_off?.should be_true
          end
        end

        context "as 'completed'" do
          let(:lease) { FactoryGirl.create(:completed_lease) }

          it "remains 'completed'" do
            lease.completed?.should be_true
            lease.charge_off
            lease.completed?.should be_true
          end
        end
      end

      describe "complete" do
        context "as 'active'" do
         let(:lease) { FactoryGirl.create(:active_lease) }

          it "transitions to 'completed'" do
            lease.active?.should be_true
            lease.complete
            lease.completed?.should be_true
          end
        end

        context "as 'charged_off'" do
          let(:lease) { FactoryGirl.create(:charged_off_lease) }

          it "remains 'charged_off'" do
            lease.charged_off?.should be_true
            lease.complete
            lease.charged_off?.should be_true
          end
        end

        context "as 'completed'" do
          let(:lease) { FactoryGirl.create(:completed_lease) }

          it "remains 'completed'" do
            lease.completed?.should be_true
            lease.complete
            lease.completed?.should be_true
          end
        end
      end
    end

    describe "states", :states => true do
      describe "active" do
        let(:lease) { FactoryGirl.create(:active_lease) }

        context "with invalid attributes" do
          it "does not save without lease_application" do
            lease.lease_application = nil
            expect{ lease.save! }.to raise_error
          end  
        end
        
        context "with valid attributes" do
          it "saves successfully" do
            expect{ lease.save! }.to_not raise_error
          end
          
          it "is active?" do
            lease.active?.should be_true
          end
        end
      end

      describe "charged_off" do
        let(:lease) { FactoryGirl.create(:charged_off_lease) }

        context "with invalid attributes" do
          it "does not save without lease_application" do
            lease.lease_application = nil
            expect{ lease.save! }.to raise_error
          end  
        end
        
        context "with valid attributes" do
          it "saves successfully" do
            expect{ lease.save! }.to_not raise_error
          end
          
          it "is charged_off?" do
            lease.charged_off?.should be_true
          end
        end
      end

      describe "completed" do
        let(:lease) { FactoryGirl.create(:completed_lease) }

        context "with invalid attributes" do
          it "does not save without lease_application" do
            lease.lease_application = nil
            expect{ lease.save! }.to raise_error
          end  
        end
        
        context "with valid attributes" do
          it "saves successfully" do
            expect{ lease.save! }.to_not raise_error
          end
          
          it "is completed?" do
            lease.completed?.should be_true
          end
        end
      end
    end
  end

  # Behavior
  #----------------------------------------------------------------------------
  describe "behavior", :behavior => true do
    describe "scopes", :scopes => true do
      describe "active" do
        it "returns active leases" do
          active_1 = FactoryGirl.create(:active_lease)
          active_2 = FactoryGirl.create(:active_lease)
          charged_off_1 = FactoryGirl.create(:charged_off_lease)
          
          leases = Lease.active
          leases.should eq([active_1, active_2])
        end
      end

      describe "charged_off" do
        it "returns charged_off leases" do
          active_1 = FactoryGirl.create(:active_lease)
          charged_off_1 = FactoryGirl.create(:charged_off_lease)
          charged_off_2 = FactoryGirl.create(:charged_off_lease)
          
          leases = Lease.charged_off
          leases.should eq([charged_off_1, charged_off_2])
        end
      end

      describe "completed" do
        it "returns completed leases" do
          active_1 = FactoryGirl.create(:active_lease)
          completed_1 = FactoryGirl.create(:completed_lease)
          completed_2 = FactoryGirl.create(:completed_lease)
          
          leases = Lease.completed
          leases.should eq([completed_1, completed_2])
        end
      end
    end
    
    describe "instance methods", :instance_methods => true do
      describe "name" do
        let(:lease) do
          store = FactoryGirl.create(:store, :name => "Demo Store")
          lease_application = FactoryGirl.build(:unclaimed_lease_application, :store => store, number_of_products: 0)
          lease_application.products << FactoryGirl.build(:product, :lease_application => lease_application, :name => "Demo Product 1")
          lease_application.products << FactoryGirl.build(:product, :lease_application => lease_application, :name => "Demo Product 2")
          lease_application.save!
          lease = FactoryGirl.create(:lease, :lease_application => lease_application)
          lease.reload
        end

        it "returns name and products" do
          lease.name.should eq("Demo Store: Demo Product 1, Demo Product 2")
        end
      end

      describe "products_list" do
        let(:lease) do
          lease_application = FactoryGirl.build(:unclaimed_lease_application, number_of_products: 0)
          lease_application.products << FactoryGirl.build(:product, :lease_application => lease_application, :name => "Demo Product 1")
          lease_application.products << FactoryGirl.build(:product, :lease_application => lease_application, :name => "Demo Product 2")
          lease_application.save!
          lease = FactoryGirl.create(:lease, :lease_application => lease_application)
          lease.reload
        end

        it "returns csv products list" do
          lease.products_list.should eq("Demo Product 1, Demo Product 2")
        end
      end

      describe "principal_balance" do
        let(:lease) do
          lease_application = FactoryGirl.build(:unclaimed_lease_application, number_of_products: 0)
          lease_application.products << FactoryGirl.build(:product, :lease_application => lease_application, :price => BigDecimal.new("89.95"))
          lease_application.products << FactoryGirl.build(:product, :lease_application => lease_application, :price => BigDecimal.new("53.02"))
          lease_application.save!
          lease = FactoryGirl.create(:lease, :lease_application => lease_application)
          lease.reload
        end

        it "returns total price of all products" do
          lease.principal_balance.should eq(BigDecimal.new("-142.97"))
        end
      end        

      describe "charges_total" do
        let(:lease) do
          lease = FactoryGirl.create(:lease)
        end

        it "returns charges total" do
          total = BigDecimal.new("0.0")
          lease.charges.each do |charge|
            total = total + charge.total
          end
          lease.charges_total.should eq(total)
        end
      end

=begin
      describe "fees_total" do
        let(:lease) do
          lease_application = FactoryGirl.build(:unclaimed_lease_application, number_of_products: 0)
          lease_application.products << FactoryGirl.build(:product, :lease_application => lease_application, :price => BigDecimal.new("89.95"))
          lease_application.products << FactoryGirl.build(:product, :lease_application => lease_application, :price => BigDecimal.new("53.02"))
          lease_application.save!
          lease = FactoryGirl.create(:lease, :lease_application => lease_application)
        end

        it "returns fees total" do
          lease.fees_total.should eq(BigDecimal.new("-15.00"))
        end
      end

      describe "payments_total" do
        let(:lease) do
          lease_application = FactoryGirl.build(:unclaimed_lease_application, number_of_products: 0)
          lease_application.products << FactoryGirl.build(:product, :lease_application => lease_application, :price => BigDecimal.new("89.95"))
          lease_application.products << FactoryGirl.build(:product, :lease_application => lease_application, :price => BigDecimal.new("53.02"))
          lease_application.save!
          lease = FactoryGirl.create(:lease, :lease_application => lease_application)
        end


        it "returns payments total" do
          lease.payments_total.should eq(BigDecimal.new("145.00"))
        end
      end

      describe "percentage_paid" do
        let(:lease) do
          lease_application = FactoryGirl.build(:unclaimed_lease_application, number_of_products: 0)
          lease_application.products << FactoryGirl.build(:product, :lease_application => lease_application, :price => BigDecimal.new("89.95"))
          lease_application.products << FactoryGirl.build(:product, :lease_application => lease_application, :price => BigDecimal.new("53.02"))
          lease_application.save!
          lease = FactoryGirl.create(:lease, :lease_application => lease_application)
        end
        
        it "returns percentage paid" do
          total_owed = (BigDecimal.new("-142.97") * lease.markup).round(2) + BigDecimal.new("-15.00")
          total_paid = BigDecimal.new("145.00")
          percentage = (total_paid / total_owed) * BigDecimal.new("100")
          lease.percentage_paid.should eq(percentage)
        end
      end

      describe "buy_now_price" do
        context "with no payments" do
          context "with no fees" do
            let(:lease) do
            end
  
            it "returns buy now price" do
              total_owed = (BigDecimal.new("-142.97") * BigDecimal.new("2.70")).round(2)
              payoff_percentage = BigDecimal.new("0.55")
              buy_now = (BigDecimal.new("-1.00") * total_owed * payoff_percentage).round(2)
              lease.buy_now_price.should eq(buy_now)
            end
          end

          context "with fees" do
            let(:lease) do
            end
  
            it "returns buy now price" do
              balance_owed = (BigDecimal.new("-142.97") * BigDecimal.new("2.70")).round(2)
              payoff_percentage = BigDecimal.new("0.55")
              buy_now = (balance_owed * payoff_percentage).round(2) + BigDecimal.new("-15.0")
              buy_now = BigDecimal.new("-1.00") * buy_now
              lease.buy_now_price.should eq(buy_now)
            end
          end
        end

        context "with payments" do
          context "with no fees" do
            let(:lease) do
            end
  
            it "returns buy now price" do
              balance_owed = (BigDecimal.new("-142.97") * BigDecimal.new("2.70")).round(2)
              balance_owed = balance_owed + BigDecimal.new("95.00")
              payoff_percentage = BigDecimal.new("0.55")
              buy_now = (balance_owed * payoff_percentage).round(2)
              buy_now = BigDecimal.new("-1.00") * buy_now
              lease.buy_now_price.should eq(buy_now)
            end
          end

          context "with fees" do
            let(:lease) do
            end
  
            it "returns buy now price" do
              balance_owed = (BigDecimal.new("-142.97") * BigDecimal.new("2.70")).round(2)
              balance_owed = balance_owed + BigDecimal.new("95.00")
              payoff_percentage = BigDecimal.new("0.55")
              buy_now = (balance_owed * payoff_percentage).round(2) + BigDecimal.new("-15.0")
              buy_now = BigDecimal.new("-1.00") * buy_now
              lease.buy_now_price.should eq(buy_now)
            end
          end
        end
      end

      describe "balance" do
        context "with no payments, fees, or charges" do
          let(:lease) do
            lease_application = FactoryGirl.build(:unclaimed_lease_application, number_of_products: 0)
            lease_application.products << FactoryGirl.build(:product, :lease_application => lease_application, :price => BigDecimal.new("89.95"))
            lease_application.products << FactoryGirl.build(:product, :lease_application => lease_application, :price => BigDecimal.new("53.02"))
            lease_application.save!
            lease = FactoryGirl.create(:lease, :lease_application => lease_application)
          end

          it "returns 0.0" do
            lease.balance.should eq(BigDecimal.new("0.0"))
          end
        end

        context "with only charges" do
          let(:lease) do
            lease_application = FactoryGirl.build(:unclaimed_lease_application, number_of_products: 0)
            lease_application.products << FactoryGirl.build(:product, :lease_application => lease_application, :price => BigDecimal.new("89.95"))
            lease_application.products << FactoryGirl.build(:product, :lease_application => lease_application, :price => BigDecimal.new("53.02"))
            lease_application.save!
            lease = FactoryGirl.create(:lease, :lease_application => lease_application)
          end
  
          it "returns correct balance" do
            lease = FactoryGirl.create(:unclaimed_lease)
            lease.charges << FactoryGirl.create(:charge, :lease => lease, :total => BigDecimal.new("-123.32"))
            lease.charges << FactoryGirl.create(:charge, :lease => lease, :total => BigDecimal.new("-76.45"))
            lease.balance.should eq(BigDecimal.new("-199.77"))
          end
        end
          
        context "with charges and fees" do
          it "returns correct balance" do
            lease = FactoryGirl.create(:unclaimed_lease)
            lease.charges << FactoryGirl.create(:charge, :lease => lease, :total => BigDecimal.new("-123.32"))
            lease.charges << FactoryGirl.create(:charge, :lease => lease, :total => BigDecimal.new("-76.45"))
            lease.fees << FactoryGirl.create(:fee, :lease => lease, :total => BigDecimal.new("-10.00"))
            lease.balance.should eq(BigDecimal.new("-209.77"))
          end            
        end

        context "with charges, fees, and payments" do
          it "returns correct balance" do
            customer = FactoryGirl.create(:customer_with_payment_profiles)
            lease = FactoryGirl.create(:unclaimed_lease, :customer => customer)
            lease.charges << FactoryGirl.create(:charge, :lease => lease, :total => BigDecimal.new("-123.32"))
            lease.charges << FactoryGirl.create(:charge, :lease => lease, :total => BigDecimal.new("-76.45"))
            lease.fees << FactoryGirl.create(:fee, :lease => lease, :total => BigDecimal.new("-10.00"))
            lease.fees << FactoryGirl.create(:fee, :lease => lease, :total => BigDecimal.new("-15.00"))
            lease.payments << FactoryGirl.create(:payment, :lease => lease, :total => BigDecimal.new("55.12"))
            lease.payments << FactoryGirl.create(:payment, :lease => lease, :total => BigDecimal.new("43.21"))
            lease.balance.should eq(BigDecimal.new("-126.44"))
          end
        end
      end

      describe "account_transactions" do
        context "with no payments" do
          let(:lease) { FactoryGirl.create(:unclaimed_lease) }

          context "with no charges" do
            it "has no lease transactions" do
              lease.lease_transactions.should be_empty
            end
          end

          context "with only charges" do
            it "has no lease transactions" do
              lease.charges << FactoryGirl.create(:charge, :lease => lease, :total => BigDecimal.new("-123.32"))
              lease.charges << FactoryGirl.create(:charge, :lease => lease, :total => BigDecimal.new("-76.45"))
              lease.save!
              lease.lease_transactions.should be_empty
            end
          end
          
          context "with only charges and fees" do
            it "has no lease transactions" do
              lease.charges << FactoryGirl.create(:charge, :lease => lease, :total => BigDecimal.new("-123.32"))
              lease.charges << FactoryGirl.create(:charge, :lease => lease, :total => BigDecimal.new("-76.45"))
              lease.fees << FactoryGirl.create(:fee, :lease => lease, :total => BigDecimal.new("-10.00"))
              lease.save!
              lease.lease_transactions.should be_empty
            end            
          end
        end

        context "with one payment", :failing_balance => true do
          let(:lease) { FactoryGirl.create(:claimed_lease) }

          context "with no charges" do
            it "has no lease transactions" do
              lease.save!
              lease.lease_transactions.should be_empty
            end            
          end

          context "with one charge" do
            context "with charge > payment" do
              before(:each) do
                lease.charges << FactoryGirl.create(:charge, :lease => lease, :total => BigDecimal.new("-354.32"))
                lease.payments << FactoryGirl.create(:payment, :lease => lease, :total => BigDecimal.new("25.00"))
                lease.save!
              end

              it "creates 1 lease transaction" do
                lease.lease_transactions.count.should eq(1)
              end

              it "applies payment to the first charge" do
                lease.charges.first.balance.should eq(BigDecimal.new("-329.32"))
              end

              it "leaves payment as 'paid_off?'" do
                lease.payments.first.paid_off?.should be_true
              end
            end

            context "with charge == payment" do
              before(:each) do
                lease.charges << FactoryGirl.create(:charge, :lease => lease, :total => BigDecimal.new("-354.32"))
                lease.payments << FactoryGirl.create(:payment, :lease => lease, :total => BigDecimal.new("354.32"))
                lease.save!
              end

              it "creates 1 lease transaction" do
                lease.lease_transactions.count.should eq(1)
              end

              it "applies payment to the first charge" do
                lease.charges.first.balance.should eq(BigDecimal.new("0.0"))
              end

              it "leaves charge as 'paid_off?'" do
                lease.charges.first.paid_off?.should be_true
              end

              it "leaves payment as 'paid_off?'" do
                lease.payments.first.paid_off?.should be_true
              end
            end

            context "with charge < payment" do
              before(:each) do
                lease.charges << FactoryGirl.create(:charge, :lease => lease, :total => BigDecimal.new("-354.32"))
                lease.payments << FactoryGirl.create(:payment, :lease => lease, :total => BigDecimal.new("400.00"))
                lease.save!
              end

              it "creates 1 lease transaction" do
                lease.lease_transactions.count.should eq(1)
              end

              it "applies payment to the first charge" do
                lease.charges.first.balance.should eq(BigDecimal.new("0.0"))
              end

              it "leaves charge as 'paid_off?'" do
                lease.charges.first.paid_off?.should be_true
              end

              it "leaves balance on payment" do
                lease.payments.first.balance.should eq(BigDecimal.new("45.68"))
              end
            end
          end

          context "with multiple charges" do
            context "with charge > payment" do
              before(:each) do
                lease.charges << FactoryGirl.create(:charge, :lease => lease, :total => BigDecimal.new("-234.30"))
                lease.charges << FactoryGirl.create(:charge, :lease => lease, :total => BigDecimal.new("-120.02"))
                lease.payments << FactoryGirl.create(:payment, :lease => lease, :total => BigDecimal.new("25.00"))
                lease.save!
              end

              it "creates 1 lease transaction" do
                lease.lease_transactions.count.should eq(1)
              end

              it "applies payment to the first charge" do
                lease.charges.first.balance.should eq(BigDecimal.new("-209.30"))
              end

              it "does not alter the second charge" do
                lease.charges.second.balance.should eq(BigDecimal.new("-120.02"))
              end

              it "leaves payment as 'paid_off?'" do
                lease.payments.first.paid_off?.should be_true
              end
            end

            context "with total charges == payment" do
              before(:each) do
                lease.charges << FactoryGirl.create(:charge, :lease => lease, :total => BigDecimal.new("-234.30"))
                lease.charges << FactoryGirl.create(:charge, :lease => lease, :total => BigDecimal.new("-120.02"))
                lease.payments << FactoryGirl.create(:payment, :lease => lease, :total => BigDecimal.new("354.32"))
                lease.save!
              end

              it "creates 2 lease transactions" do
                lease.lease_transactions.count.should eq(2)
              end

              it "applies payment to the first charge" do
                lease.charges.first.balance.should eq(BigDecimal.new("0.0"))
              end

              it "applies payment to the second charge" do
                lease.charges.second.balance.should eq(BigDecimal.new("0.0"))
              end

              it "leaves first charge as 'paid_off?'" do
                lease.charges.first.paid_off?.should be_true
              end

              it "leaves second charge as 'paid_off?'" do
                lease.charges.second.paid_off?.should be_true
              end

              it "leaves payment as 'paid_off?'" do
                lease.payments.first.paid_off?.should be_true
              end
            end

            context "with total charges < payment" do
              before(:each) do
                lease.charges << FactoryGirl.create(:charge, :lease => lease, :total => BigDecimal.new("-234.30"))
                lease.charges << FactoryGirl.create(:charge, :lease => lease, :total => BigDecimal.new("-120.02"))
                lease.payments << FactoryGirl.create(:payment, :lease => lease, :total => BigDecimal.new("400.00"))
                lease.save!
              end

              it "creates 2 lease transactions" do
                lease.lease_transactions.count.should eq(2)
              end

              it "applies payment to the first charge" do
                lease.charges.first.balance.should eq(BigDecimal.new("0.0"))
              end

              it "applies payment to the second charge" do
                lease.charges.second.balance.should eq(BigDecimal.new("0.0"))
              end

              it "leaves first charge as 'paid_off?'" do
                lease.charges.first.paid_off?.should be_true
              end

              it "leaves second charge as 'paid_off?'" do
                lease.charges.second.paid_off?.should be_true
              end

              it "leaves balance on payment" do
                lease.payments.first.balance.should eq(BigDecimal.new("45.68"))
              end
            end
          end
        end
      end
=end
    end

=begin
    describe "generate_charge" do
      it "creates new charge" do
        lease = FactoryGirl.create(:lease)
        lease.charges.count.should eq(0)
        lease.generate_charge
        lease.reload
        lease.charges.count.should eq(1)
      end
    end
=end
  end
end




=begin
      let(:lease) do
        #Unclaimed
        store = FactoryGirl.create(:store, :name => "Demo Store")
        lease = FactoryGirl.build(:unclaimed_lease, :store => store, number_of_products: 0)
        product_1 = FactoryGirl.build(:product, :lease => lease, :name => "Demo Product 1", :price => BigDecimal.new("89.95"))
        product_2 = FactoryGirl.build(:product, :lease => lease, :name => "Demo Product 2", :price => BigDecimal.new("53.02"))
        lease.products << product_1
        lease.products << product_2
        lease.save!
        lease.reload
      end
      
      context "as 'active'" do
        before(:each) do
          #Claiming
          customer = FactoryGirl.create(:customer_with_payment_profiles)
          lease.customer = customer
          lease.claim
          #Submitting
          lease.payment_frequency = "weekly"
          lease.submit
          #Approval
          lease.approve
          #Beginning
          lease.markup = BigDecimal.new("2.65")
          lease.
          #Adding Fees
          lease.fees << FactoryGirl.create(:fee, :lease => lease, :total => BigDecimal.new("-10.00"))
          lease.fees << FactoryGirl.create(:fee, :lease => lease, :total => BigDecimal.new("-5.00"))
          #Adding Payments
          payment_profile_id = lease.customer.payment_profiles.first.cim_customer_payment_profile_id
          lease.payments << FactoryGirl.create(:payment, :lease => lease, :total => BigDecimal.new("100.00"))
          lease.payments << FactoryGirl.create(:payment, :lease => lease, :total => BigDecimal.new("45.00"))
          lease.reload
        end
      end
=end