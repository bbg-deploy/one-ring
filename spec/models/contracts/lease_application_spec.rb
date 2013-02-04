require 'spec_helper'

describe LeaseApplication do
  # Model & Factory Validation
  #----------------------------------------------------------------------------
  describe "factory validation", :factory_validation => true do
    specify { LeaseApplication.new.should be_an_instance_of(LeaseApplication) }

    describe "unclaimed_lease factory", :test => true do
      let(:lease_application) { FactoryGirl.create(:unclaimed_lease_application) }

      it_behaves_like "valid record", :unclaimed_lease_application
      
      it "does not have a customer" do
        lease_application.customer.should be_nil
      end

      it "is claimed" do
        lease_application.claimed?.should be_false
      end
    end

    describe "claimed_lease_application factory" do
      let(:lease_application) {FactoryGirl.create(:claimed_lease_application)}

      it_behaves_like "valid record", :claimed_lease_application

      it "has a customer" do
        lease_application.customer.should_not be_nil
      end

      it "is claimed" do
        lease_application.claimed?.should be_true
      end
    end

    describe "submitted_lease_application factory" do
      let(:lease_application) {FactoryGirl.create(:submitted_lease_application)}

      it_behaves_like "valid record", :submitted_lease_application

      it "has a customer" do
        lease_application.customer.should_not be_nil
      end

      it "is submitted" do
        lease_application.submitted?.should be_true
      end
    end

    describe "denied_lease_application factory" do
      let(:lease_application) {FactoryGirl.create(:denied_lease_application)}

      it_behaves_like "valid record", :denied_lease_application  

      it "has a credit_decision" do
        lease_application.credit_decision.should_not be_nil
      end

      it "is denied" do
        lease_application.denied?.should be_true
      end
    end

    describe "approved_lease_application factory" do
      let(:lease_application) {FactoryGirl.create(:approved_lease_application)}

      it_behaves_like "valid record", :approved_lease_application

      it "has a credit_decision" do
        lease_application.credit_decision.should_not be_nil
      end

      it "is approved" do
        lease_application.approved?.should be_true
      end
    end

    describe "finalized_lease_application factory" do
      let(:lease_application) {FactoryGirl.create(:finalized_lease_application)}

      it_behaves_like "valid record", :finalized_lease_application

      it "has id_verified" do
        lease_application.id_verified.should be_true
      end

      it "has an initial_lease_choice" do
        lease_application.initial_lease_choice.should_not be_nil
      end

      it "is finalized" do
        lease_application.finalized?.should be_true
      end
    end

    describe "completed_lease_application factory" do
      let(:lease_application) {FactoryGirl.create(:completed_lease_application)}

      it_behaves_like "valid record", :completed_lease_application

      it "has an lease" do
        lease_application.lease.should_not be_nil
      end

      it "is completed" do
        lease_application.completed?.should be_true
      end
    end
  end

  # Associations
  #----------------------------------------------------------------------------
  describe "associations", :associations => true do
    describe "customer" do
      it_behaves_like "immutable belongs_to", :claimed_lease_application, :customer
      it_behaves_like "deletable belongs_to", :claimed_lease_application, :customer
    end
  
    describe "store" do
      it_behaves_like "required belongs_to", :unclaimed_lease_application, :store
      it_behaves_like "immutable belongs_to", :unclaimed_lease_application, :store
      it_behaves_like "deletable belongs_to", :unclaimed_lease_application, :store
    end    
  end

  # State Machine
  #----------------------------------------------------------------------------
  describe "state machine", :state_machine => true do
    describe "initial conditions" do
      it "defaults to 'unclaimed'" do
        lease_application = FactoryGirl.create(:unclaimed_lease_application)
        lease_application.unclaimed?.should be_true
      end
    end

    describe "events", :events => true do
      describe "claim" do
        context "as 'unclaimed'" do
          let(:lease_application) { FactoryGirl.create(:unclaimed_lease_application) }

          context "without customer" do
            it "remains 'unclaimed'" do
              lease_application.unclaimed?.should be_true
              lease_application.claim
              lease_application.unclaimed?.should be_true              
            end
          end

          context "with customer" do
            it "transitions to 'claimed'" do
              lease_application.customer = FactoryGirl.create(:customer)
              lease_application.unclaimed?.should be_true
              lease_application.claim
              lease_application.claimed?.should be_true
            end
          end
        end

        context "as 'claimed'" do
          let(:lease_application) { FactoryGirl.create(:claimed_lease_application) }
          
          it "remains 'claimed'" do
            lease_application.claimed?.should be_true
            lease_application.claim
            lease_application.claimed?.should be_true
          end
        end

        context "as 'submitted'" do
          let(:lease_application) { FactoryGirl.create(:submitted_lease_application) }
          
          it "remains 'submitted'" do
            lease_application.submitted?.should be_true
            lease_application.claim
            lease_application.submitted?.should be_true
          end
        end

        context "as 'denied'" do
          let(:lease_application) { FactoryGirl.create(:denied_lease_application) }

          it "remains 'denied'" do
            lease_application.denied?.should be_true
            lease_application.claim
            lease_application.denied?.should be_true
          end
        end

        context "as 'approved'" do
          let(:lease_application) { FactoryGirl.create(:approved_lease_application) }

          it "remains 'approved'" do
            lease_application.approved?.should be_true
            lease_application.claim
            lease_application.approved?.should be_true
          end
        end

        context "as 'finalized'" do
          let(:lease_application) { FactoryGirl.create(:finalized_lease_application) }

          it "remains 'finalized'" do
            lease_application.finalized?.should be_true
            lease_application.claim
            lease_application.finalized?.should be_true
          end
        end

        context "as 'completed'" do
          let(:lease_application) { FactoryGirl.create(:completed_lease_application) }

          it "remains 'completed'" do
            lease_application.completed?.should be_true
            lease_application.claim
            lease_application.completed?.should be_true
          end
        end
      end

      describe "submit" do
        context "as 'unclaimed'" do
          let(:lease_application) { FactoryGirl.create(:unclaimed_lease_application) }

          context "without customer" do
            it "remains 'unclaimed'" do
              lease_application.unclaimed?.should be_true
              lease_application.submit
              lease_application.unclaimed?.should be_true              
            end
          end

          context "with customer" do
            it "remains 'unclaimed'" do
              lease_application.customer = FactoryGirl.create(:customer)
              lease_application.unclaimed?.should be_true
              lease_application.submit
              lease_application.unclaimed?.should be_true              
            end
          end
        end

        context "as 'claimed'" do
          let(:lease_application) { FactoryGirl.create(:claimed_lease_application) }
          
          context "without application variables" do
            it "remains 'unclaimed'" do
              lease_application.claimed?.should be_true
              lease_application.submit
              lease_application.claimed?.should be_true              
            end
          end

          context "with application variables" do
            before(:each) do
              lease_application.time_at_address = 4.years.ago
              lease_application.rent_or_own = "rent"
              lease_application.rent_payment = BigDecimal.new("400.00")
            end

            it "transitions to 'submitted'" do
              lease_application.claimed?.should be_true
              lease_application.submit
              lease_application.submitted?.should be_true
            end            
          end
        end

        context "as 'submitted'" do
          let(:lease_application) { FactoryGirl.create(:submitted_lease_application) }
          
          it "remains 'submitted'" do
            lease_application.submitted?.should be_true
            lease_application.submit
            lease_application.submitted?.should be_true
          end
        end

        context "as 'denied'" do
          let(:lease_application) { FactoryGirl.create(:denied_lease_application) }

          it "remains 'denied'" do
            lease_application.denied?.should be_true
            lease_application.submit
            lease_application.denied?.should be_true
          end
        end

        context "as 'approved'" do
          let(:lease_application) { FactoryGirl.create(:approved_lease_application) }

          it "remains 'approved'" do
            lease_application.approved?.should be_true
            lease_application.submit
            lease_application.approved?.should be_true
          end
        end

        context "as 'finalized'" do
          let(:lease_application) { FactoryGirl.create(:finalized_lease_application) }

          it "remains 'finalized'" do
            lease_application.finalized?.should be_true
            lease_application.submit
            lease_application.finalized?.should be_true
          end
        end

        context "as 'completed'" do
          let(:lease_application) { FactoryGirl.create(:completed_lease_application) }

          it "remains 'completed'" do
            lease_application.completed?.should be_true
            lease_application.submit
            lease_application.completed?.should be_true
          end
        end
      end

      describe "deny" do
        context "as 'unclaimed'" do
          let(:lease_application) { FactoryGirl.create(:unclaimed_lease_application) }

          context "without customer" do
            it "remains 'unclaimed'" do
              lease_application.unclaimed?.should be_true
              lease_application.deny
              lease_application.unclaimed?.should be_true              
            end
          end

          context "with customer" do
            it "remains 'unclaimed'" do
              lease_application.customer = FactoryGirl.create(:customer)
              lease_application.unclaimed?.should be_true
              lease_application.deny
              lease_application.unclaimed?.should be_true              
            end
          end
        end

        context "as 'claimed'" do
          let(:lease_application) { FactoryGirl.create(:claimed_lease_application) }
          
          it "remains 'claimed'" do
            lease_application.claimed?.should be_true
            lease_application.deny
            lease_application.claimed?.should be_true
          end
        end

        context "as 'submitted'" do                      
          let(:lease_application) { FactoryGirl.create(:submitted_lease_application) }

          context "without credit_decision" do
            it "remains 'submitted'" do
              lease_application.submitted?.should be_true
              lease_application.deny
              lease_application.submitted?.should be_true
            end
          end

          context "with credit_decision" do
            it "remains 'submitted'" do
              lease_application.credit_decision = FactoryGirl.create(:denied_credit_decision, :lease_application => lease_application)
              lease_application.submitted?.should be_true
              lease_application.deny
              lease_application.denied?.should be_true
            end
          end
        end

        context "as 'denied'" do
          let(:lease_application) { FactoryGirl.create(:denied_lease_application) }

          it "remains 'denied'" do
            lease_application.denied?.should be_true
            lease_application.deny
            lease_application.denied?.should be_true
          end
        end

        context "as 'approved'" do
          let(:lease_application) { FactoryGirl.create(:approved_lease_application) }

          it "transitions to 'denied'" do
            lease_application.approved?.should be_true
            lease_application.deny
            lease_application.denied?.should be_true
          end
        end

        context "as 'finalized'" do
          let(:lease_application) { FactoryGirl.create(:finalized_lease_application) }

          it "transitions to 'denied'" do
            lease_application.finalized?.should be_true
            lease_application.deny
            lease_application.denied?.should be_true
          end
        end

        context "as 'completed'" do
          let(:lease_application) { FactoryGirl.create(:completed_lease_application) }

          it "remains 'completed'" do
            lease_application.completed?.should be_true
            lease_application.deny
            lease_application.completed?.should be_true
          end
        end
      end

      describe "approve" do
        context "as 'unclaimed'" do
          let(:lease_application) { FactoryGirl.create(:unclaimed_lease_application) }

          context "without customer" do
            it "remains 'unclaimed'" do
              lease_application.unclaimed?.should be_true
              lease_application.approve
              lease_application.unclaimed?.should be_true              
            end
          end

          context "with customer" do
            it "remains 'unclaimed'" do
              lease_application.customer = FactoryGirl.create(:customer)
              lease_application.unclaimed?.should be_true
              lease_application.approve
              lease_application.unclaimed?.should be_true              
            end
          end
        end

        context "as 'claimed'" do
          let(:lease_application) { FactoryGirl.create(:claimed_lease_application) }
          
          it "remains 'claimed'" do
            lease_application.claimed?.should be_true
            lease_application.approve
            lease_application.claimed?.should be_true
          end
        end

        context "as 'submitted'" do                      
          let(:lease_application) { FactoryGirl.create(:submitted_lease_application) }

          context "without credit_decision" do
            it "remains 'submitted'" do
              lease_application.submitted?.should be_true
              lease_application.approve
              lease_application.submitted?.should be_true
            end
          end

          context "with credit_decision" do
            it "transitions 'approved'" do
              lease_application.credit_decision = FactoryGirl.create(:approved_credit_decision, :lease_application => lease_application)
              lease_application.submitted?.should be_true
              lease_application.approve
              lease_application.approved?.should be_true
            end
          end
        end

        context "as 'denied'" do
          let(:lease_application) { FactoryGirl.create(:denied_lease_application) }

          it "transitions to 'approved'" do
            lease_application.denied?.should be_true
            lease_application.approve
            lease_application.approved?.should be_true
          end
        end

        context "as 'approved'" do
          let(:lease_application) { FactoryGirl.create(:approved_lease_application) }

          it "remains 'approved'" do
            lease_application.approved?.should be_true
            lease_application.approve
            lease_application.approved?.should be_true
          end
        end

        context "as 'finalized'" do
          let(:lease_application) { FactoryGirl.create(:finalized_lease_application) }

          it "remains 'finalized'" do
            lease_application.finalized?.should be_true
            lease_application.approve
            lease_application.finalized?.should be_true
          end
        end

        context "as 'completed'" do
          let(:lease_application) { FactoryGirl.create(:completed_lease_application) }

          it "remains 'completed'" do
            lease_application.completed?.should be_true
            lease_application.approve
            lease_application.completed?.should be_true
          end
        end
      end

      describe "finalize" do
        context "as 'unclaimed'" do
          let(:lease_application) { FactoryGirl.create(:unclaimed_lease_application) }

          context "without customer" do
            it "remains 'unclaimed'" do
              lease_application.unclaimed?.should be_true
              lease_application.finalize
              lease_application.unclaimed?.should be_true              
            end
          end

          context "with customer" do
            it "remains 'unclaimed'" do
              lease_application.customer = FactoryGirl.create(:customer)
              lease_application.unclaimed?.should be_true
              lease_application.finalize
              lease_application.unclaimed?.should be_true              
            end
          end
        end

        context "as 'claimed'" do
          let(:lease_application) { FactoryGirl.create(:claimed_lease_application) }
          
          it "remains 'claimed'" do
            lease_application.claimed?.should be_true
            lease_application.finalize
            lease_application.claimed?.should be_true
          end
        end

        context "as 'submitted'" do                      
          let(:lease_application) { FactoryGirl.create(:submitted_lease_application) }

          context "without credit_decision" do
            it "remains 'submitted'" do
              lease_application.submitted?.should be_true
              lease_application.finalize
              lease_application.submitted?.should be_true
            end
          end

          context "with credit_decision" do
            it "remains 'submitted'" do
              lease_application.credit_decision = FactoryGirl.create(:approved_credit_decision, :lease_application => lease_application)
              lease_application.submitted?.should be_true
              lease_application.finalize
              lease_application.submitted?.should be_true
            end
          end
        end

        context "as 'denied'" do
          let(:lease_application) { FactoryGirl.create(:denied_lease_application) }

          it "transitions to 'approved'" do
            lease_application.denied?.should be_true
            lease_application.finalize
            lease_application.denied?.should be_true
          end
        end

        context "as 'approved'" do
          let(:lease_application) { FactoryGirl.create(:approved_lease_application) }


          context "without initial_lease_choice" do
            it "remains 'approved'" do
              lease_application.approved?.should be_true
              lease_application.initial_lease_choice = nil
              lease_application.id_verified = true
              lease_application.finalize
              lease_application.approved?.should be_true
            end
          end

          context "without id_verified" do
            it "remains 'approved'" do
              lease_application.approved?.should be_true
              lease_application.initial_lease_choice = 'low_cost'
              lease_application.id_verified = false
              lease_application.finalize
              lease_application.approved?.should be_true
            end
          end

          context "with initial_lease_application and id_verified" do
            it "transitions to 'finalized'" do
              lease_application.approved?.should be_true
              lease_application.initial_lease_choice = 'low_cost'
              lease_application.id_verified = true
              lease_application.finalize
              lease_application.finalized?.should be_true
            end
          end
        end

        context "as 'finalized'" do
          let(:lease_application) { FactoryGirl.create(:finalized_lease_application) }

          it "remains 'finalized'" do
            lease_application.finalized?.should be_true
            lease_application.finalize
            lease_application.finalized?.should be_true
          end
        end

        context "as 'completed'" do
          let(:lease_application) { FactoryGirl.create(:completed_lease_application) }

          it "remains 'completed'" do
            lease_application.completed?.should be_true
            lease_application.finalize
            lease_application.completed?.should be_true
          end
        end
      end
    end

    describe "states", :states => true do
      describe "unclaimed" do
        context "with invalid attributes" do
          it "does not save without store" do
            expect{ lease_application = FactoryGirl.create(:unclaimed_lease_application, :store => nil) }.to raise_error
          end
  
          it "does not save without matching_email" do
            expect{ lease_application = FactoryGirl.create(:unclaimed_lease_application, :matching_email => nil) }.to raise_error
          end
  
          it "does not save without products" do
            expect{ lease_application = FactoryGirl.create(:unclaimed_lease_application, number_of_products: 0) }.to raise_error
          end
        end

        context "with valid attributes" do
          it "saves successfully" do
            expect{ lease_application = FactoryGirl.create(:unclaimed_lease_application)}.to_not raise_error
          end
        end
      end      

      describe "claimed" do
        let(:lease_application) { FactoryGirl.create(:claimed_lease_application) }

        context "with invalid attributes" do
          it "does not save without store" do
            lease_application.store = nil
            expect{ lease_application.save! }.to raise_error
          end  

          it "does not save without customer" do
            lease_application.customer = nil
            expect{ lease_application.save! }.to raise_error
          end  

          it "does not save without matching_email" do
            lease_application.matching_email = nil
            expect{ lease_application.save! }.to raise_error
          end  
        end

        context "with valid attributes" do
          it "saves successfully" do
            expect{ lease_application = FactoryGirl.create(:claimed_lease_application) }.to_not raise_error
          end
          
          it "is claimed?" do
            lease_application.claimed?.should be_true
          end
        end
      end

      describe "submitted" do
        let(:lease_application) { FactoryGirl.create(:submitted_lease_application) }

        context "with invalid attributes" do
          it "does not save without store" do
            lease_application.store = nil
            expect{ lease_application.save! }.to raise_error
          end  

          it "does not save without customer" do
            lease_application.customer = nil
            expect{ lease_application.save! }.to raise_error
          end  

          it "does not save without matching_email" do
            lease_application.matching_email = nil
            expect{ lease_application.save! }.to raise_error
          end  

          it "does not save without time_at_address" do
            lease_application.time_at_address = nil
            expect{ lease_application.save! }.to raise_error
          end

          it "does not save without rent_or_own" do
            lease_application.rent_or_own = nil
            expect{ lease_application.save! }.to raise_error
          end

          it "does not save without rent_payment" do
            lease_application.rent_payment = nil
            expect{ lease_application.save! }.to raise_error
          end
        end
        
        context "with valid attributes" do
          it "saves successfully" do
            expect{ lease_application = FactoryGirl.create(:submitted_lease_application) }.to_not raise_error
          end
          
          it "is submitted?" do
            lease_application.submitted?.should be_true
          end
        end
      end

      describe "denied" do
        let(:lease_application) { FactoryGirl.create(:denied_lease_application) }

        context "with invalid attributes" do
          it "does not save without store" do
            lease_application.store = nil
            expect{ lease_application.save! }.to raise_error
          end  

          it "does not save without customer" do
            lease_application.customer = nil
            expect{ lease_application.save! }.to raise_error
          end  

          it "does not save without matching_email" do
            lease_application.matching_email = nil
            expect{ lease_application.save! }.to raise_error
          end  

          it "does not save without time_at_address" do
            lease_application.time_at_address = nil
            expect{ lease_application.save! }.to raise_error
          end

          it "does not save without rent_or_own" do
            lease_application.rent_or_own = nil
            expect{ lease_application.save! }.to raise_error
          end

          it "does not save without rent_payment" do
            lease_application.rent_payment = nil
            expect{ lease_application.save! }.to raise_error
          end

          it "does not save without credit_decision" do
            lease_application.credit_decision.destroy
            lease_application.reload
            lease_application.credit_decision.should be_nil
            expect{ lease_application.save! }.to raise_error
          end  
        end
        
        context "with valid attributes" do
          it "saves successfully" do
            expect{ lease_application = FactoryGirl.create(:denied_lease_application) }.to_not raise_error
          end
          
          it "is denied?" do
            lease_application.denied?.should be_true
          end
        end
      end

      describe "approved" do
        let(:lease_application) { FactoryGirl.create(:approved_lease_application) }

        context "with invalid attributes" do
          it "does not save without store" do
            lease_application.store = nil
            expect{ lease_application.save! }.to raise_error
          end  

          it "does not save without customer" do
            lease_application.customer = nil
            expect{ lease_application.save! }.to raise_error
          end  

          it "does not save without matching_email" do
            lease_application.matching_email = nil
            expect{ lease_application.save! }.to raise_error
          end  

          it "does not save without time_at_address" do
            lease_application.time_at_address = nil
            expect{ lease_application.save! }.to raise_error
          end

          it "does not save without rent_or_own" do
            lease_application.rent_or_own = nil
            expect{ lease_application.save! }.to raise_error
          end

          it "does not save without rent_payment" do
            lease_application.rent_payment = nil
            expect{ lease_application.save! }.to raise_error
          end

          it "does not save without credit_decision" do
            lease_application.credit_decision.destroy
            lease_application.reload
            lease_application.credit_decision.should be_nil
            expect{ lease_application.save! }.to raise_error
          end  
        end
        
        context "with valid attributes" do
          it "saves successfully" do
            expect{ lease_application = FactoryGirl.create(:approved_lease_application) }.to_not raise_error
          end
          
          it "is approved?" do
            lease_application.approved?.should be_true
          end
        end
      end

      describe "finalized" do
        let(:lease_application) { FactoryGirl.create(:finalized_lease_application) }

        context "with invalid attributes" do
          it "does not save without store" do
            lease_application.store = nil
            expect{ lease_application.save! }.to raise_error
          end  

          it "does not save without customer" do
            lease_application.customer = nil
            expect{ lease_application.save! }.to raise_error
          end  

          it "does not save without matching_email" do
            lease_application.matching_email = nil
            expect{ lease_application.save! }.to raise_error
          end  

          it "does not save without time_at_address" do
            lease_application.time_at_address = nil
            expect{ lease_application.save! }.to raise_error
          end

          it "does not save without rent_or_own" do
            lease_application.rent_or_own = nil
            expect{ lease_application.save! }.to raise_error
          end

          it "does not save without rent_payment" do
            lease_application.rent_payment = nil
            expect{ lease_application.save! }.to raise_error
          end

          it "does not save without credit_decision" do
            lease_application.credit_decision.destroy
            lease_application.reload
            lease_application.credit_decision.should be_nil
            expect{ lease_application.save! }.to raise_error
          end  

          it "does not save without id_verified" do
            lease_application.id_verified = nil
            expect{ lease_application.save! }.to raise_error
          end  

          it "does not save with id_verified = false" do
            lease_application.id_verified = false
            expect{ lease_application.save! }.to raise_error
          end  

          it "does not save without initial_lease_choice" do
            lease_application.initial_lease_choice = nil
            expect{ lease_application.save! }.to raise_error
          end  

          it "does not save with invalid initial_lease_choice" do
            lease_application.initial_lease_choice = 'other'
            expect{ lease_application.save! }.to raise_error
          end  
        end
        
        context "with valid attributes" do
          it "saves successfully" do
            expect{ lease_application = FactoryGirl.create(:finalized_lease_application) }.to_not raise_error
          end
          
          it "is finalized?" do
            lease_application.finalized?.should be_true
          end
        end
      end

      describe "completed" do
        let(:lease_application) { FactoryGirl.create(:completed_lease_application) }

        context "with invalid attributes" do
          it "does not save without store" do
            lease_application.store = nil
            expect{ lease_application.save! }.to raise_error
          end  

          it "does not save without customer" do
            lease_application.customer = nil
            expect{ lease_application.save! }.to raise_error
          end  

          it "does not save without matching_email" do
            lease_application.matching_email = nil
            expect{ lease_application.save! }.to raise_error
          end  

          it "does not save without time_at_address" do
            lease_application.time_at_address = nil
            expect{ lease_application.save! }.to raise_error
          end

          it "does not save without rent_or_own" do
            lease_application.rent_or_own = nil
            expect{ lease_application.save! }.to raise_error
          end

          it "does not save without rent_payment" do
            lease_application.rent_payment = nil
            expect{ lease_application.save! }.to raise_error
          end

          it "does not save without credit_decision" do
            lease_application.credit_decision.destroy
            lease_application.reload
            lease_application.credit_decision.should be_nil
            expect{ lease_application.save! }.to raise_error
          end  

          it "does not save without id_verified" do
            lease_application.id_verified = nil
            expect{ lease_application.save! }.to raise_error
          end  

          it "does not save with id_verified = false" do
            lease_application.id_verified = false
            expect{ lease_application.save! }.to raise_error
          end  

          it "does not save without initial_lease_choice" do
            lease_application.initial_lease_choice = nil
            expect{ lease_application.save! }.to raise_error
          end  

          it "does not save with invalid initial_lease_choice" do
            lease_application.initial_lease_choice = 'other'
            expect{ lease_application.save! }.to raise_error
          end  

          it "does not save without a lease" do
            lease_application.lease.destroy
            lease_application.reload
            lease_application.lease.should be_nil
            expect{ lease_application.save! }.to raise_error
          end  
        end
        
        context "with valid attributes" do
          it "saves successfully" do
            expect{ lease_application = FactoryGirl.create(:completed_lease_application) }.to_not raise_error
          end
          
          it "is finalized?" do
            lease_application.completed?.should be_true
          end
        end
      end
    end
  end

  # Behavior
  #----------------------------------------------------------------------------
  describe "behavior", :behavior => true do
    describe "scopes", :scopes => true do
      describe "self.unclaimed" do
        it "returns unclaimed lease applications" do
          unclaimed_1 = FactoryGirl.create(:unclaimed_lease_application)
          unclaimed_2 = FactoryGirl.create(:unclaimed_lease_application)
          claimed_1 = FactoryGirl.create(:claimed_lease_application)
          
          lease_applications = LeaseApplication.unclaimed
          lease_applications.should eq([unclaimed_1, unclaimed_2])
        end
      end      

      describe "self.claimed" do
        it "returns claimed lease_applications" do
          unclaimed_1 = FactoryGirl.create(:unclaimed_lease_application)
          claimed_1 = FactoryGirl.create(:claimed_lease_application)
          claimed_2 = FactoryGirl.create(:claimed_lease_application)
          
          lease_applications = LeaseApplication.claimed
          lease_applications.should eq([claimed_1, claimed_2])
        end
      end

      describe "self.submitted" do
        it "returns submitted leases" do
          claimed_1 = FactoryGirl.create(:claimed_lease_application)
          submitted_1 = FactoryGirl.create(:submitted_lease_application)
          submitted_2 = FactoryGirl.create(:submitted_lease_application)
          
          lease_applications = LeaseApplication.submitted
          lease_applications.should eq([submitted_1, submitted_2])
        end
      end

      describe "self.denied" do
        it "returns denied leases" do
          approved_1 = FactoryGirl.create(:approved_lease_application)
          denied_1 = FactoryGirl.create(:denied_lease_application)
          denied_2 = FactoryGirl.create(:denied_lease_application)
          
          lease_applications = LeaseApplication.denied
          lease_applications.should eq([denied_1, denied_2])
        end
      end

      describe "self.approved" do
        it "returns approved leases" do
          submitted_1 = FactoryGirl.create(:submitted_lease_application)
          approved_1 = FactoryGirl.create(:approved_lease_application)
          approved_2 = FactoryGirl.create(:approved_lease_application)
          
          lease_applications = LeaseApplication.approved
          lease_applications.should eq([approved_1, approved_2])
        end
      end

      describe "self.finalized" do
        it "returns finalized leases" do
          approved_1 = FactoryGirl.create(:approved_lease_application)
          finalized_1 = FactoryGirl.create(:finalized_lease_application)
          finalized_2 = FactoryGirl.create(:finalized_lease_application)
          
          lease_applications = LeaseApplication.finalized
          lease_applications.should eq([finalized_1, finalized_2])
        end
      end

      describe "self.completed" do
        it "returns completed leases" do
          approved_1 = FactoryGirl.create(:approved_lease_application)
          completed_1 = FactoryGirl.create(:completed_lease_application)
          completed_2 = FactoryGirl.create(:completed_lease_application)
          
          lease_applications = LeaseApplication.completed
          lease_applications.should eq([completed_1, completed_2])
        end
      end
    end

    describe "instance methods", :instance_methods => true do

      describe "name" do
        let(:lease_application) do
          store = FactoryGirl.create(:store, :name => "Demo Store")
          lease_application = FactoryGirl.build(:unclaimed_lease_application, :store => store, number_of_products: 2)
        end

        it "returns name and products" do
          lease_application.name.should eq("Demo Store: Demo Product, Demo Product")
        end
      end

      describe "products_list" do
        let(:lease_application) do
          lease_application = FactoryGirl.build(:unclaimed_lease_application, number_of_products: 2)
        end

        it "returns csv products list" do
          lease_application.products_list.should eq("Demo Product, Demo Product")
        end
      end

      describe "products_total_price" do
        let(:lease_application) do
          lease_application = FactoryGirl.build(:unclaimed_lease_application, number_of_products: 2)
        end

        it "returns total price of products" do
          lease_application.products_total_price.should eq(BigDecimal.new("599.10"))
        end
      end
    end
  end
end
