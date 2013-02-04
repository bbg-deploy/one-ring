module DebitableSharedExamples
  # acts_as_charge
  #----------------------------------------------------------------------------  
  shared_examples_for "is_debitable attributes" do |factory|
    describe "total" do
      it_behaves_like "attr_accessible", factory, :total,
        [BigDecimal.new("-100"), -100, BigDecimal.new("-25.50"), -44.36], #Valid values
        [nil, BigDecimal.new("0"), BigDecimal.new("1"), "x"] #Invalid values

      describe "rounding" do
        context "on create" do
          it "rounds up to two decimal places" do
            transaction = FactoryGirl.create(factory, :total => BigDecimal.new("-98.765"))
            transaction.total.should eq(BigDecimal.new("-98.77"))
          end
      
          it "rounds down to two decimal places" do
            transaction = FactoryGirl.create(factory, :total => BigDecimal.new("-98.761"))
            transaction.total.should eq(BigDecimal.new("-98.76"))
          end
        end
        
        context "on update" do
          it "rounds up to two decimal places" do
            transaction = FactoryGirl.create(factory, :total => BigDecimal.new("-98.76"))
            transaction.update_attributes({:total => BigDecimal.new("-95.765")})
            transaction.total.should eq(BigDecimal.new("-95.77"))
          end
      
          it "rounds down to two decimal places" do
            transaction = FactoryGirl.create(factory, :total => BigDecimal.new("-98.76"))
            transaction.update_attributes({:total => BigDecimal.new("-95.761")})
            transaction.total.should eq(BigDecimal.new("-95.76"))
          end
        end
      end
    end

    describe "balance" do
      it "is set to 'total' by default" do
        transaction = FactoryGirl.create(factory, :total => BigDecimal.new("-98.76"))
        transaction.balance.should eq(transaction.total)
        transaction.balance.should eq(BigDecimal.new("-98.76"))
      end

      describe "rounding" do
        context "on create" do
          it "rounds up to two decimal places" do
            transaction = FactoryGirl.create(factory, :total => BigDecimal.new("-98.765"))
            transaction.balance.should eq(BigDecimal.new("-98.77"))
          end
      
          it "rounds down to two decimal places" do
            transaction = FactoryGirl.create(factory, :total => BigDecimal.new("-98.761"))
            transaction.balance.should eq(BigDecimal.new("-98.76"))
          end
        end
        context "after add_credit" do
          it "rounds up to two decimal places" do
            transaction = FactoryGirl.create(factory, :total => BigDecimal.new("-98.76"))
            transaction.add_credit(BigDecimal.new("10.009"))
            transaction.balance.should eq(BigDecimal.new("-88.75"))
          end
      
          it "rounds down to two decimal places" do
            transaction = FactoryGirl.create(factory, :total => BigDecimal.new("-98.76"))
            transaction.add_credit(BigDecimal.new("10.001"))
            transaction.balance.should eq(BigDecimal.new("-88.76"))
          end          
        end
      end
    end
  end

  shared_examples_for "is_debitable state_machine" do |factory|
    describe "initial conditions" do
      let(:transaction) { FactoryGirl.create(factory) }
      
      it "should have state 'incomplete'" do
        transaction.save!
        transaction.incomplete?.should be_true        
      end
    end

    describe "events", :events => true do
      describe "recalculate" do
        context "as 'incomplete'" do
          context "with balance remaining" do
            let(:transaction) { FactoryGirl.create(factory) }
            before(:each) do
              transaction.update_attribute(:balance, BigDecimal.new("-5.0"))
            end

            it "remains 'incomplete'" do
              transaction.incomplete?.should be_true
              transaction.recalculate
              transaction.incomplete?.should be_true
            end
          end

          context "with balance == 0" do
            let(:transaction) { FactoryGirl.create(factory) }
            before(:each) do
              transaction.update_attribute(:balance, BigDecimal.new("0.0"))
            end

            it "transitions to 'complete'" do
              transaction.incomplete?.should be_true
              transaction.recalculate
              transaction.complete?.should be_true
            end
          end
        end

        context "as 'complete'" do
          context "with balance remaining" do
            let(:transaction) { FactoryGirl.create(factory) }
            before(:each) do
              transaction.update_attribute(:balance, BigDecimal.new("0.0"))
              transaction.recalculate
              transaction.update_attribute(:balance, BigDecimal.new("-5.0"))
            end

            it "transitions to 'incomplete'" do
              transaction.complete?.should be_true
              transaction.recalculate
              transaction.incomplete?.should be_true
            end
          end

          context "with balance == 0" do
            let(:transaction) { FactoryGirl.create(factory) }
            before(:each) do
              transaction.update_attribute(:balance, BigDecimal.new("0.0"))
              transaction.recalculate
              transaction.update_attribute(:balance, BigDecimal.new("0.0"))
            end

            it "remains 'complete'" do
              transaction.complete?.should be_true
              transaction.recalculate
              transaction.complete?.should be_true
            end
          end
        end
      end
    end

    describe "transitions", :transitions => true do
    end
  end

  shared_examples_for "is_debitable behavior" do |factory|
    describe "is_debitable?" do
      it "returns true" do
        transaction = FactoryGirl.create(factory)
        transaction.is_debitable?.should be_true
      end
    end

    describe "is_creditable?" do
      it "returns false" do
        transaction = FactoryGirl.create(factory)
        transaction.is_creditable?.should be_false
      end
    end

    describe "add_credit" do
      let(:transaction) { FactoryGirl.create(factory) }

      context "with payment = nil" do
        it "raises error" do
          original_balance = transaction.balance
          credit = nil
          expect{ transaction.add_credit(credit) }.to raise_error
        end

        it "maintains balance" do
          original_balance = transaction.balance
          credit = nil
          expect{ transaction.add_credit(credit) }.to raise_error
          transaction.balance.should eq(original_balance)
        end
      end

      context "with non-BigDecimal amount" do
        it "raises error" do
          credit = 9.99
          expect{ transaction.add_credit(credit) }.to raise_error
        end

        it "maintains balance" do
          original_balance = transaction.balance
          credit = -9.99
          expect{ transaction.add_credit(credit) }.to raise_error
          transaction.balance.should eq(original_balance)
        end
      end

      context "with BigDecimal amount" do
        context "with amount < 0" do
          it "raises error" do
            credit = BigDecimal.new("-1.0")
            expect{ transaction.add_credit(credit) }.to raise_error 
          end

          it "does not change charge balance" do
            original_balance = transaction.balance
            credit = BigDecimal.new("-1.0")
            expect{ transaction.add_credit(payment) }.to raise_error
            transaction.reload
            transaction.balance.should eq(original_balance)            
          end
        end
        
        context "with amount < remaining balance" do
          it "credits balance by amount" do
            original_balance = transaction.balance
            credit = BigDecimal.new("10.0")
            transaction.add_credit(credit)
            transaction.reload
            transaction.balance.should eq(original_balance + credit)
          end

          it "is 'incomplete'" do
            credit = BigDecimal.new("10.0")
            transaction.add_credit(credit)
            transaction.reload
            transaction.incomplete?.should be_true
          end
        end

        context "with amount == remaining balance" do
          it "credits balance by amount" do
            original_balance = transaction.balance
            credit = transaction.balance * BigDecimal("-1.0")
            transaction.add_credit(credit)
            transaction.reload
            transaction.balance.should eq(original_balance + credit)
          end          

          it "is 'complete'" do
            credit = transaction.balance * BigDecimal("-1.0")
            transaction.add_credit(credit)
            transaction.reload
            transaction.complete?.should be_true
          end
        end

        context "with amount > remaining balance" do
          it "raises error" do
            credit = (transaction.balance * BigDecimal("-1.0")) + BigDecimal.new("1.0")
            expect{ transaction.add_credit(credit) }.to raise_error 
          end

          it "does not change charge balance" do
            original_balance = transaction.balance
            credit = (transaction.balance * BigDecimal("-1.0")) + BigDecimal.new("1.0")
            expect{ transaction.add_credit(payment) }.to raise_error
            transaction.reload
            transaction.balance.should eq(original_balance)            
          end
        end
      end
    end

    describe "reverse_credit" do
      let(:transaction) { FactoryGirl.create(factory) }

      context "with amount = nil" do
        it "raises error" do
          original_balance = transaction.balance
          credit = nil
          expect{ transaction.reverse_credit(credit) }.to raise_error
        end

        it "maintains balance" do
          original_balance = transaction.balance
          credit = nil
          expect{ transaction.reverse_credit(credit) }.to raise_error
          transaction.balance.should eq(original_balance)
        end
      end

      context "with non-BigDecimal amount" do
        it "raises error" do
          credit = 9.99
          expect{ transaction.reverse_credit(credit) }.to raise_error
        end

        it "maintains balance" do
          original_balance = transaction.balance
          credit = 9.99
          expect{ transaction.reverse_credit(credit) }.to raise_error
          transaction.balance.should eq(original_balance)
        end
      end

      context "with BigDecimal amount" do
        before(:each) do
          halfway = transaction.total * BigDecimal.new("-0.50")
          transaction.add_credit(halfway)
          transaction.reload
        end
        
        context "with amount < 0" do
          it "raises error" do
            credit = BigDecimal.new("-1.0")
            expect{ transaction.reverse_credit(credit) }.to raise_error 
          end

          it "does not change charge balance" do
            original_balance = transaction.balance
            credit = BigDecimal.new("-1.0")
            expect{ transaction.reverse_credit(payment) }.to raise_error
            transaction.reload
            transaction.balance.should eq(original_balance)            
          end
        end

        context "with amount < remaining balance" do
          it "debits balance by amount" do
            original_balance = transaction.balance
            credit = BigDecimal.new("10.0")
            transaction.reverse_credit(credit)
            transaction.reload
            transaction.balance.should eq(original_balance - credit)
          end

          it "is 'incomplete'" do
            credit = BigDecimal.new("10.0")
            transaction.reverse_credit(credit)
            transaction.reload
            transaction.incomplete?.should be_true
          end
        end

        context "with amount == paid balance" do
          it "increases balance by amount" do
            original_balance = transaction.balance
            credit = (transaction.total - transaction.balance) * BigDecimal.new("-1.0")
            transaction.reverse_credit(credit)
            transaction.reload
            transaction.balance.should eq(original_balance - credit)
          end          

          it "equal to original total" do
            credit = (transaction.total - transaction.balance) * BigDecimal.new("-1.0")
            transaction.reverse_credit(credit)
            transaction.reload
            transaction.balance.should eq(transaction.total)
          end
        end

        context "with amount > paid balance" do
          it "raises error" do
            credit = (transaction.total - transaction.balance - BigDecimal.new("1.0")) * BigDecimal.new("-1.0")
            expect{ transaction.add_credit(credit) }.to raise_error 
          end

          it "does not change charge balance" do
            original_balance = transaction.balance
            credit = (transaction.total - transaction.balance - BigDecimal.new("1.0")) * BigDecimal.new("-1.0")
            expect{ transaction.add_credit(credit) }.to raise_error
            transaction.reload
            transaction.balance.should eq(original_balance)            
          end
        end
      end
    end
  end
end