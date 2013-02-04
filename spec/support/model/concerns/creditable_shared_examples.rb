module CreditableSharedExamples
  shared_examples_for "is_creditable attributes" do |factory|
    describe "total" do
      it_behaves_like "attr_accessible", factory, :total,
        [100, 25.50], #Valid values
        [nil, 0, -1, "x"] #Invalid values

      it "rounds up to two decimal places" do
        transaction = FactoryGirl.create(factory, :total => 98.765)
        transaction.total.should eq(BigDecimal.new("98.77"))
      end
  
      it "rounds down to two decimal places" do
        transaction = FactoryGirl.create(factory, :total => 98.761)
        transaction.total.should eq(BigDecimal.new("98.76"))
      end
    end

    describe "date" do
      it_behaves_like "attr_accessible", factory, :date,
        [1.day.ago, 3.days.ago, 14.days.from_now], #Valid values
        [nil] #Invalid values
    end

    describe "payment_type" do
      it_behaves_like "attr_accessible", factory, :payment_type,
        [:credit_card, :echeck, :cash], #Valid values
        [] #Invalid values (Nothing is invalid, since invalid gets set to 'credit_card' by default)
        
      it "is set to 'credit_card' by default" do
        transaction = FactoryGirl.create(factory, :payment_type => nil)
        transaction.should be_valid
        transaction.payment_type.credit_card?.should be_true
      end
    end
  end

  shared_examples_for "is_creditable state_machine" do |factory|
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
              transaction.update_attribute(:balance, BigDecimal.new("5.0"))
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
              transaction.update_attribute(:balance, BigDecimal.new("5.0"))
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

  shared_examples_for "is_processable state_machine" do |factory|
    describe "initial conditions" do
      let(:transaction) { FactoryGirl.create(factory, :total => BigDecimal.new("100")) }
      
      it "should have state 'unprocessed'" do
        transaction.save!
        transaction.unprocessed?.should be_true        
      end
    end

    describe "events", :events => true do
      describe "receive" do
        let(:transaction) { FactoryGirl.create(factory, :total => BigDecimal.new("100")) }

        context "as 'unprocessed'" do
          it "should transition to 'received'" do
            transaction.unprocessed?.should be_true
            transaction.receive
            transaction.received?.should be_true
          end
        end

        context "as 'received'" do
          before(:each) do
            transaction.receive            
          end

          it "should remain 'received'" do
            transaction.received?.should be_true
            transaction.receive
            transaction.received?.should be_true
          end
        end

        context "as 'approved'" do
          before(:each) do
            transaction.receive
            transaction.approve
          end

          it "should remain 'approved'" do
            transaction.approved?.should be_true
            transaction.receive
            transaction.approved?.should be_true
          end
        end

        context "as 'denied'" do
          before(:each) do
            transaction.receive
            transaction.deny
          end

          it "should remain 'denied'" do
            transaction.denied?.should be_true
            transaction.receive
            transaction.denied?.should be_true
          end
        end
      end

      describe "approve" do
        let(:transaction) { FactoryGirl.create(factory, :total => BigDecimal.new("100")) }

        context "as 'unprocessed'" do
          it "should remain to 'unprocessed'" do
            transaction.unprocessed?.should be_true
            transaction.approve
            transaction.unprocessed?.should be_true
          end
        end

        context "as 'received'" do
          before(:each) do
            transaction.receive            
          end

          it "should transition to 'approved'" do
            transaction.received?.should be_true
            transaction.approve
            transaction.approved?.should be_true
          end
        end

        context "as 'approved'" do
          before(:each) do
            transaction.receive
            transaction.approve
          end

          it "should remain 'approved'" do
            transaction.approved?.should be_true
            transaction.approve
            transaction.approved?.should be_true
          end
        end

        context "as 'denied'" do
          before(:each) do
            transaction.receive
            transaction.deny
          end

          it "should remain 'denied'" do
            transaction.denied?.should be_true
            transaction.approve
            transaction.approved?.should be_true
          end
        end
      end

      describe "deny" do
        let(:transaction) { FactoryGirl.create(factory, :total => BigDecimal.new("100")) }

        context "as 'unprocessed'" do
          it "should remain to 'unprocessed'" do
            transaction.unprocessed?.should be_true
            transaction.deny
            transaction.unprocessed?.should be_true
          end
        end

        context "as 'received'" do
          before(:each) do
            transaction.receive            
          end

          it "should transition to 'approved'" do
            transaction.received?.should be_true
            transaction.deny
            transaction.denied?.should be_true
          end
        end

        context "as 'approved'" do
          before(:each) do
            transaction.receive
            transaction.approve
          end

          it "should remain 'approved'" do
            transaction.approved?.should be_true
            transaction.deny
            transaction.denied?.should be_true
          end
        end

        context "as 'denied'" do
          before(:each) do
            transaction.receive
            transaction.deny
          end

          it "should remain 'denied'" do
            transaction.denied?.should be_true
            transaction.deny
            transaction.denied?.should be_true
          end
        end
      end
    end
    
    describe "transitions", :transitions => true do
    end
  end
end