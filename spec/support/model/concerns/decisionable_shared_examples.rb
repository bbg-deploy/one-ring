module DecisionableSharedExamples
  shared_examples_for "decisionable state_machine" do |factory, approved_factory, denied_factory|
    describe "initial conditions" do
      it "defaults to 'undecisioned'" do
        model = FactoryGirl.create(factory)
        model.undecisioned?.should be_true
      end
    end

    describe "events", :events => true do
      describe "decision" do
        let(:model) { FactoryGirl.create(factory) }

        context "as 'undecisioned'" do
          context "with no customer" do
            let(:model) { FactoryGirl.create(factory, :customer => nil) }
            it "remains 'undecisioned'" do
              model.undecisioned?.should be_true
              model.decision
              model.undecisioned?.should be_true              
            end
          end
          
          context "with customer" do
            let(:model) { FactoryGirl.create(factory) }
            it "transitions to 'decisioned'" do
              model.undecisioned?.should be_true
              model.decision
              model.decisioned?.should be_true
            end
          end
        end

        context "as 'decisioned'" do
          let(:model) { FactoryGirl.create(factory) }
          before(:each) do
            model.decision
          end
          
          it "remains 'decisioned'" do
            model.decisioned?.should be_true
            model.decision
            model.decisioned?.should be_true
          end            
        end

        context "as 'approved'" do
          let(:model) { FactoryGirl.create(approved_factory) }
          
          it "remains 'approved'" do
            model.approved?.should be_true
            model.decision
            model.approved?.should be_true
          end            
        end

        context "as 'denied'" do
          let(:model) { FactoryGirl.create(denied_factory) }

          it "remains 'denied'" do
            model.denied?.should be_true
            model.decision
            model.denied?.should be_true
          end            
        end
      end

      describe "approve" do
        let(:model) { FactoryGirl.create(factory) }

        context "as 'undecisioned'" do
          context "with no customer" do
            let(:model) { FactoryGirl.create(factory, :customer => nil) }
            it "remains 'undecisioned'" do
              model.undecisioned?.should be_true
              model.approve
              model.undecisioned?.should be_true              
            end
          end
          
          context "with customer" do
            let(:model) { FactoryGirl.create(factory) }
            it "remains 'undecisioned'" do
              model.undecisioned?.should be_true
              model.approve
              model.undecisioned?.should be_true
            end            
          end
        end

        context "as 'decisioned'" do
          let(:model) { FactoryGirl.create(factory) }
          before(:each) do
            model.decision
          end
          
          it "remains 'decisioned'" do
            model.decisioned?.should be_true
            model.approve
            model.decisioned?.should be_true
          end            
        end

        context "as 'approved'" do
          let(:model) { FactoryGirl.create(approved_factory) }
          
          it "remains 'approved'" do
            model.approved?.should be_true
            model.approve
            model.approved?.should be_true
          end            
        end

        context "as 'denied'" do
          let(:model) { FactoryGirl.create(denied_factory) }

          it "transitions to 'approved'" do
            model.denied?.should be_true
            model.approve
            model.approved?.should be_true
          end            
        end
      end

      describe "deny" do
        let(:model) { FactoryGirl.create(factory) }

        context "as 'undecisioned'" do
          context "with no customer" do
            let(:model) { FactoryGirl.create(factory, :customer => nil) }
            it "remains 'undecisioned'" do
              model.undecisioned?.should be_true
              model.deny
              model.undecisioned?.should be_true              
            end
          end
          
          context "with customer" do
            let(:model) { FactoryGirl.create(factory) }
            it "remains 'undecisioned'" do
              model.undecisioned?.should be_true
              model.deny
              model.undecisioned?.should be_true
            end
          end
        end

        context "as 'decisioned'" do
          let(:model) { FactoryGirl.create(factory) }
          before(:each) do
            model.decision
          end
          
          it "remains 'decisioned'" do
            model.decisioned?.should be_true
            model.deny
            model.decisioned?.should be_true
          end
        end

        context "as 'approved'" do
          let(:model) { FactoryGirl.create(approved_factory) }
          
          it "transitions to 'denied'" do
            model.approved?.should be_true
            model.deny
            model.denied?.should be_true
          end            
        end

        context "as 'denied'" do
          let(:model) { FactoryGirl.create(denied_factory) }

          it "remains 'denied'" do
            model.denied?.should be_true
            model.deny
            model.denied?.should be_true
          end            
        end
      end
    end
  end

  shared_examples_for "decisionable behavior" do |factory, approved_factory, denied_factory|
    describe "class methods" do
      describe "self.undecisioned_contracts" do
        let(:undecisioned_1) { FactoryGirl.create(factory) }
        let(:undecisioned_2) { FactoryGirl.create(factory) }
        before(:each) do
          undecisioned_1.reload
          undecisioned_2.reload
        end
  
        it "returns correct count" do
          klass = undecisioned_1.class
          klass.undecisioned_contracts.count.should eq(2)  
        end
  
        it "returns correct contracts" do
          klass = undecisioned_1.class
          klass.undecisioned_contracts.should eq([undecisioned_1, undecisioned_2])
        end      
      end    

      describe "self.decisioned_contracts" do
        let(:undecisioned_1) { FactoryGirl.create(factory) }
        let(:decisioned_1) { FactoryGirl.create(factory) }
        let(:decisioned_2) { FactoryGirl.create(factory) }
        before(:each) do
          undecisioned_1.reload
          decisioned_1.reload
          decisioned_1.decision
          decisioned_2.reload
          decisioned_2.decision
        end
  
        it "returns correct count" do
          klass = decisioned_1.class
          klass.decisioned_contracts.count.should eq(2)  
        end
  
        it "returns correct contracts" do
          klass = decisioned_1.class
          klass.decisioned_contracts.should eq([decisioned_1, decisioned_2])
        end      
      end    

      describe "self.approved_contracts" do
        let(:decisioned_1) { FactoryGirl.create(factory) }
        let(:approved_1) { FactoryGirl.create(approved_factory) }
        let(:approved_2) { FactoryGirl.create(approved_factory) }
        before(:each) do
          decisioned_1.reload
          decisioned_1.decision
          approved_1.reload
          approved_2.reload
        end
  
        it "returns correct count" do
          klass = approved_1.class
          klass.approved_contracts.count.should eq(2)  
        end
  
        it "returns correct contracts" do
          klass = approved_1.class
          klass.approved_contracts.should eq([approved_1, approved_2])
        end
      end

      describe "self.denied_contracts" do
        let(:decisioned_1) { FactoryGirl.create(factory) }
        let(:denied_1) { FactoryGirl.create(denied_factory) }
        let(:denied_2) { FactoryGirl.create(denied_factory) }
        before(:each) do
          decisioned_1.reload
          decisioned_1.decision
          denied_1.reload
          denied_2.reload
        end
  
        it "returns correct count" do
          klass = denied_1.class
          klass.denied_contracts.count.should eq(2)  
        end
  
        it "returns correct contracts" do
          klass = denied_1.class
          klass.denied_contracts.should eq([denied_1, denied_2])
        end
      end
    end
  end
end