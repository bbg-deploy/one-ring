require 'spec_helper'

describe Application do
  # Model & Factory Validation
  #----------------------------------------------------------------------------
  describe "factory validation", :factory_validation => true do
    specify { Application.new.should be_an_instance_of(Application) }

    describe "unclaimed_lease factory", :test => true do
      let(:application) { FactoryGirl.create(:unclaimed_application) }

      it_behaves_like "valid record", :unclaimed_application
      
      it "does not have a customer_account_number" do
        application.customer_account_number.should be_nil
      end

      it "is not claimed" do
        application.claimed?.should be_false
      end
    end

    describe "claimed_application factory" do
      let(:application) {FactoryGirl.create(:claimed_application)}

      it_behaves_like "valid record", :claimed_application

      it "has a customer_account_number" do
        application.customer_account_number.should_not be_nil
      end

      it "is claimed" do
        application.claimed?.should be_true
      end
    end

    describe "submitted_application factory" do
      let(:application) {FactoryGirl.create(:submitted_application)}

      it_behaves_like "valid record", :submitted_application

      it "has a customer_account_number" do
        application.customer_account_number.should_not be_nil
      end

      it "is submitted" do
        application.submitted?.should be_true
      end
    end

    describe "denied_application factory" do
      let(:application) {FactoryGirl.create(:denied_application)}

      it_behaves_like "valid record", :denied_application  

#      it "has a credit_decision" do
#        application.credit_decision.should_not be_nil
#      end

      it "is denied" do
        application.denied?.should be_true
      end
    end

    describe "approved_application factory" do
      let(:application) {FactoryGirl.create(:approved_application)}

      it_behaves_like "valid record", :approved_application

#      it "has a credit_decision" do
#        application.credit_decision.should_not be_nil
#      end

      it "is approved" do
        application.approved?.should be_true
      end
    end

    describe "finalized_application factory" do
      let(:application) {FactoryGirl.create(:finalized_application)}

      it_behaves_like "valid record", :finalized_application

      it "has id_verified" do
        application.id_verified.should be_true
      end

      it "has an initial_lease_choice" do
        application.initial_lease_choice.should_not be_nil
      end

      it "is finalized" do
        application.finalized?.should be_true
      end
    end

    describe "completed_application factory" do
      let(:application) {FactoryGirl.create(:completed_application)}

      it_behaves_like "valid record", :completed_application

      it "is completed" do
        application.completed?.should be_true
      end
    end
  end

  # Associations
  #----------------------------------------------------------------------------
  describe "associations", :associations => true do  
    describe "products" do
      it { has_many(:products) }
    end    
  end

  # State Machine
  #----------------------------------------------------------------------------
  describe "state machine", :state_machine => true do
    describe "initial conditions" do
      it "defaults to 'unclaimed'" do
        application = FactoryGirl.create(:unclaimed_application)
        application.unclaimed?.should be_true
      end
    end

    describe "events", :events => true do
      describe "claim" do
        context "as 'unclaimed'" do
          let(:application) { FactoryGirl.create(:unclaimed_application) }

          context "without customer_account_number" do
            it "remains 'unclaimed'" do
              application.unclaimed?.should be_true
              application.claim
              application.unclaimed?.should be_true              
            end
          end

          context "with customer_account_number" do
            it "transitions to 'claimed'" do
              application.customer_account_number = FactoryGirl.create(:customer).account_number
              application.unclaimed?.should be_true
              application.claim
              application.claimed?.should be_true
            end
          end
        end

        context "as 'claimed'" do
          let(:application) { FactoryGirl.create(:claimed_application) }
          
          it "remains 'claimed'" do
            application.claimed?.should be_true
            application.claim
            application.claimed?.should be_true
          end
        end

        context "as 'submitted'" do
          let(:application) { FactoryGirl.create(:submitted_application) }
          
          it "remains 'submitted'" do
            application.submitted?.should be_true
            application.claim
            application.submitted?.should be_true
          end
        end

        context "as 'denied'" do
          let(:application) { FactoryGirl.create(:denied_application) }

          it "remains 'denied'" do
            application.denied?.should be_true
            application.claim
            application.denied?.should be_true
          end
        end

        context "as 'approved'" do
          let(:application) { FactoryGirl.create(:approved_application) }

          it "remains 'approved'" do
            application.approved?.should be_true
            application.claim
            application.approved?.should be_true
          end
        end

        context "as 'finalized'" do
          let(:application) { FactoryGirl.create(:finalized_application) }

          it "remains 'finalized'" do
            application.finalized?.should be_true
            application.claim
            application.finalized?.should be_true
          end
        end

        context "as 'completed'" do
          let(:application) { FactoryGirl.create(:completed_application) }

          it "remains 'completed'" do
            application.completed?.should be_true
            application.claim
            application.completed?.should be_true
          end
        end
      end

      describe "submit" do
        context "as 'unclaimed'" do
          let(:application) { FactoryGirl.create(:unclaimed_application) }

          context "without customer_account_number" do
            it "remains 'unclaimed'" do
              application.unclaimed?.should be_true
              application.submit
              application.unclaimed?.should be_true              
            end
          end

          context "with customer_account_number" do
            it "remains 'unclaimed'" do
              application.customer_account_number = FactoryGirl.create(:customer).account_number
              application.unclaimed?.should be_true
              application.submit
              application.unclaimed?.should be_true              
            end
          end
        end

        context "as 'claimed'" do
          let(:application) { FactoryGirl.create(:claimed_application) }
          
          context "without application variables" do
            it "remains 'unclaimed'" do
              application.claimed?.should be_true
              application.submit
              application.claimed?.should be_true              
            end
          end

          context "with application variables" do
            before(:each) do
              application.time_at_address = 4.years.ago
              application.rent_or_own = "rent"
              application.rent_payment = BigDecimal.new("400.00")
            end

            it "transitions to 'submitted'" do
              application.claimed?.should be_true
              application.submit
              application.submitted?.should be_true
            end            
          end
        end

        context "as 'submitted'" do
          let(:application) { FactoryGirl.create(:submitted_application) }
          
          it "remains 'submitted'" do
            application.submitted?.should be_true
            application.submit
            application.submitted?.should be_true
          end
        end

        context "as 'denied'" do
          let(:application) { FactoryGirl.create(:denied_application) }

          it "remains 'denied'" do
            application.denied?.should be_true
            application.submit
            application.denied?.should be_true
          end
        end

        context "as 'approved'" do
          let(:application) { FactoryGirl.create(:approved_application) }

          it "remains 'approved'" do
            application.approved?.should be_true
            application.submit
            application.approved?.should be_true
          end
        end

        context "as 'finalized'" do
          let(:application) { FactoryGirl.create(:finalized_application) }

          it "remains 'finalized'" do
            application.finalized?.should be_true
            application.submit
            application.finalized?.should be_true
          end
        end

        context "as 'completed'" do
          let(:application) { FactoryGirl.create(:completed_application) }

          it "remains 'completed'" do
            application.completed?.should be_true
            application.submit
            application.completed?.should be_true
          end
        end
      end

      describe "deny" do
        context "as 'unclaimed'" do
          let(:application) { FactoryGirl.create(:unclaimed_application) }

          context "without customer_account_number" do
            it "remains 'unclaimed'" do
              application.unclaimed?.should be_true
              application.deny
              application.unclaimed?.should be_true              
            end
          end

          context "with customer_account_number" do
            it "remains 'unclaimed'" do
              application.customer_account_number = FactoryGirl.create(:customer).account_number
              application.unclaimed?.should be_true
              application.deny
              application.unclaimed?.should be_true              
            end
          end
        end

        context "as 'claimed'" do
          let(:application) { FactoryGirl.create(:claimed_application) }
          
          it "remains 'claimed'" do
            application.claimed?.should be_true
            application.deny
            application.claimed?.should be_true
          end
        end

        context "as 'submitted'" do                      
          let(:application) { FactoryGirl.create(:submitted_application) }

          context "without credit_decision" do
            it "remains 'submitted'" do
              application.submitted?.should be_true
              application.deny
              application.submitted?.should be_true
            end
          end

          context "with credit_decision" do
            it "remains 'submitted'" do
              application.credit_decision = FactoryGirl.create(:denied_credit_decision, :application => application)
              application.submitted?.should be_true
              application.deny
              application.denied?.should be_true
            end
          end
        end

        context "as 'denied'" do
          let(:application) { FactoryGirl.create(:denied_application) }

          it "remains 'denied'" do
            application.denied?.should be_true
            application.deny
            application.denied?.should be_true
          end
        end

        context "as 'approved'" do
          let(:application) { FactoryGirl.create(:approved_application) }

          it "transitions to 'denied'" do
            application.approved?.should be_true
            application.deny
            application.denied?.should be_true
          end
        end

        context "as 'finalized'" do
          let(:application) { FactoryGirl.create(:finalized_application) }

          it "transitions to 'denied'" do
            application.finalized?.should be_true
            application.deny
            application.denied?.should be_true
          end
        end

        context "as 'completed'" do
          let(:application) { FactoryGirl.create(:completed_application) }

          it "remains 'completed'" do
            application.completed?.should be_true
            application.deny
            application.completed?.should be_true
          end
        end
      end

      describe "approve" do
        context "as 'unclaimed'" do
          let(:application) { FactoryGirl.create(:unclaimed_application) }

          context "without customer_account_number" do
            it "remains 'unclaimed'" do
              application.unclaimed?.should be_true
              application.approve
              application.unclaimed?.should be_true              
            end
          end

          context "with customer_account_number" do
            it "remains 'unclaimed'" do
              application.customer_account_number = FactoryGirl.create(:customer).account_number
              application.unclaimed?.should be_true
              application.approve
              application.unclaimed?.should be_true              
            end
          end
        end

        context "as 'claimed'" do
          let(:application) { FactoryGirl.create(:claimed_application) }
          
          it "remains 'claimed'" do
            application.claimed?.should be_true
            application.approve
            application.claimed?.should be_true
          end
        end

        context "as 'submitted'" do                      
          let(:application) { FactoryGirl.create(:submitted_application) }

          context "without credit_decision" do
            it "remains 'submitted'" do
              application.submitted?.should be_true
              application.approve
              application.submitted?.should be_true
            end
          end

          context "with credit_decision" do
            it "transitions 'approved'" do
              application.credit_decision = FactoryGirl.create(:approved_credit_decision, :application => application)
              application.submitted?.should be_true
              application.approve
              application.approved?.should be_true
            end
          end
        end

        context "as 'denied'" do
          let(:application) { FactoryGirl.create(:denied_application) }

          it "transitions to 'approved'" do
            application.denied?.should be_true
            application.approve
            application.approved?.should be_true
          end
        end

        context "as 'approved'" do
          let(:application) { FactoryGirl.create(:approved_application) }

          it "remains 'approved'" do
            application.approved?.should be_true
            application.approve
            application.approved?.should be_true
          end
        end

        context "as 'finalized'" do
          let(:application) { FactoryGirl.create(:finalized_application) }

          it "remains 'finalized'" do
            application.finalized?.should be_true
            application.approve
            application.finalized?.should be_true
          end
        end

        context "as 'completed'" do
          let(:application) { FactoryGirl.create(:completed_application) }

          it "remains 'completed'" do
            application.completed?.should be_true
            application.approve
            application.completed?.should be_true
          end
        end
      end

      describe "finalize" do
        context "as 'unclaimed'" do
          let(:application) { FactoryGirl.create(:unclaimed_application) }

          context "without customer_account_number" do
            it "remains 'unclaimed'" do
              application.unclaimed?.should be_true
              application.finalize
              application.unclaimed?.should be_true              
            end
          end

          context "with customer_account_number" do
            it "remains 'unclaimed'" do
              application.customer_account_number = FactoryGirl.create(:customer).account_number
              application.unclaimed?.should be_true
              application.finalize
              application.unclaimed?.should be_true              
            end
          end
        end

        context "as 'claimed'" do
          let(:application) { FactoryGirl.create(:claimed_application) }
          
          it "remains 'claimed'" do
            application.claimed?.should be_true
            application.finalize
            application.claimed?.should be_true
          end
        end

        context "as 'submitted'" do                      
          let(:application) { FactoryGirl.create(:submitted_application) }

          context "without credit_decision" do
            it "remains 'submitted'" do
              application.submitted?.should be_true
              application.finalize
              application.submitted?.should be_true
            end
          end

          context "with credit_decision" do
            it "remains 'submitted'" do
              application.credit_decision = FactoryGirl.create(:approved_credit_decision, :application => application)
              application.submitted?.should be_true
              application.finalize
              application.submitted?.should be_true
            end
          end
        end

        context "as 'denied'" do
          let(:application) { FactoryGirl.create(:denied_application) }

          it "transitions to 'approved'" do
            application.denied?.should be_true
            application.finalize
            application.denied?.should be_true
          end
        end

        context "as 'approved'" do
          let(:application) { FactoryGirl.create(:approved_application) }


          context "without initial_lease_choice" do
            it "remains 'approved'" do
              application.approved?.should be_true
              application.initial_lease_choice = nil
              application.id_verified = true
              application.finalize
              application.approved?.should be_true
            end
          end

          context "without id_verified" do
            it "remains 'approved'" do
              application.approved?.should be_true
              application.initial_lease_choice = 'low_cost'
              application.id_verified = false
              application.finalize
              application.approved?.should be_true
            end
          end

          context "with initial_application and id_verified" do
            it "transitions to 'finalized'" do
              application.approved?.should be_true
              application.initial_lease_choice = 'low_cost'
              application.id_verified = true
              application.finalize
              application.finalized?.should be_true
            end
          end
        end

        context "as 'finalized'" do
          let(:application) { FactoryGirl.create(:finalized_application) }

          it "remains 'finalized'" do
            application.finalized?.should be_true
            application.finalize
            application.finalized?.should be_true
          end
        end

        context "as 'completed'" do
          let(:application) { FactoryGirl.create(:completed_application) }

          it "remains 'completed'" do
            application.completed?.should be_true
            application.finalize
            application.completed?.should be_true
          end
        end
      end
    end

    describe "states", :states => true do
      describe "unclaimed" do
        context "with invalid attributes" do
          it "does not save without store" do
            expect{ application = FactoryGirl.create(:unclaimed_application, :store => nil) }.to raise_error
          end
  
          it "does not save without matching_email" do
            expect{ application = FactoryGirl.create(:unclaimed_application, :matching_email => nil) }.to raise_error
          end
  
          it "does not save without products" do
            expect{ application = FactoryGirl.create(:unclaimed_application, number_of_products: 0) }.to raise_error
          end
        end

        context "with valid attributes" do
          it "saves successfully" do
            expect{ application = FactoryGirl.create(:unclaimed_application)}.to_not raise_error
          end
        end
      end      

      describe "claimed" do
        let(:application) { FactoryGirl.create(:claimed_application) }

        context "with invalid attributes" do
          it "does not save without store" do
            application.store = nil
            expect{ application.save! }.to raise_error
          end  

          it "does not save without customer" do
            application.customer = nil
            expect{ application.save! }.to raise_error
          end  

          it "does not save without matching_email" do
            application.matching_email = nil
            expect{ application.save! }.to raise_error
          end  
        end

        context "with valid attributes" do
          it "saves successfully" do
            expect{ application = FactoryGirl.create(:claimed_application) }.to_not raise_error
          end
          
          it "is claimed?" do
            application.claimed?.should be_true
          end
        end
      end

      describe "submitted" do
        let(:application) { FactoryGirl.create(:submitted_application) }

        context "with invalid attributes" do
          it "does not save without store" do
            application.store = nil
            expect{ application.save! }.to raise_error
          end  

          it "does not save without customer" do
            application.customer = nil
            expect{ application.save! }.to raise_error
          end  

          it "does not save without matching_email" do
            application.matching_email = nil
            expect{ application.save! }.to raise_error
          end  

          it "does not save without time_at_address" do
            application.time_at_address = nil
            expect{ application.save! }.to raise_error
          end

          it "does not save without rent_or_own" do
            application.rent_or_own = nil
            expect{ application.save! }.to raise_error
          end

          it "does not save without rent_payment" do
            application.rent_payment = nil
            expect{ application.save! }.to raise_error
          end
        end
        
        context "with valid attributes" do
          it "saves successfully" do
            expect{ application = FactoryGirl.create(:submitted_application) }.to_not raise_error
          end
          
          it "is submitted?" do
            application.submitted?.should be_true
          end
        end
      end

      describe "denied" do
        let(:application) { FactoryGirl.create(:denied_application) }

        context "with invalid attributes" do
          it "does not save without store" do
            application.store = nil
            expect{ application.save! }.to raise_error
          end  

          it "does not save without customer" do
            application.customer = nil
            expect{ application.save! }.to raise_error
          end  

          it "does not save without matching_email" do
            application.matching_email = nil
            expect{ application.save! }.to raise_error
          end  

          it "does not save without time_at_address" do
            application.time_at_address = nil
            expect{ application.save! }.to raise_error
          end

          it "does not save without rent_or_own" do
            application.rent_or_own = nil
            expect{ application.save! }.to raise_error
          end

          it "does not save without rent_payment" do
            application.rent_payment = nil
            expect{ application.save! }.to raise_error
          end

          it "does not save without credit_decision" do
            application.credit_decision.destroy
            application.reload
            application.credit_decision.should be_nil
            expect{ application.save! }.to raise_error
          end  
        end
        
        context "with valid attributes" do
          it "saves successfully" do
            expect{ application = FactoryGirl.create(:denied_application) }.to_not raise_error
          end
          
          it "is denied?" do
            application.denied?.should be_true
          end
        end
      end

      describe "approved" do
        let(:application) { FactoryGirl.create(:approved_application) }

        context "with invalid attributes" do
          it "does not save without store" do
            application.store = nil
            expect{ application.save! }.to raise_error
          end  

          it "does not save without customer" do
            application.customer = nil
            expect{ application.save! }.to raise_error
          end  

          it "does not save without matching_email" do
            application.matching_email = nil
            expect{ application.save! }.to raise_error
          end  

          it "does not save without time_at_address" do
            application.time_at_address = nil
            expect{ application.save! }.to raise_error
          end

          it "does not save without rent_or_own" do
            application.rent_or_own = nil
            expect{ application.save! }.to raise_error
          end

          it "does not save without rent_payment" do
            application.rent_payment = nil
            expect{ application.save! }.to raise_error
          end

          it "does not save without credit_decision" do
            application.credit_decision.destroy
            application.reload
            application.credit_decision.should be_nil
            expect{ application.save! }.to raise_error
          end  
        end
        
        context "with valid attributes" do
          it "saves successfully" do
            expect{ application = FactoryGirl.create(:approved_application) }.to_not raise_error
          end
          
          it "is approved?" do
            application.approved?.should be_true
          end
        end
      end

      describe "finalized" do
        let(:application) { FactoryGirl.create(:finalized_application) }

        context "with invalid attributes" do
          it "does not save without store" do
            application.store = nil
            expect{ application.save! }.to raise_error
          end  

          it "does not save without customer" do
            application.customer = nil
            expect{ application.save! }.to raise_error
          end  

          it "does not save without matching_email" do
            application.matching_email = nil
            expect{ application.save! }.to raise_error
          end  

          it "does not save without time_at_address" do
            application.time_at_address = nil
            expect{ application.save! }.to raise_error
          end

          it "does not save without rent_or_own" do
            application.rent_or_own = nil
            expect{ application.save! }.to raise_error
          end

          it "does not save without rent_payment" do
            application.rent_payment = nil
            expect{ application.save! }.to raise_error
          end

          it "does not save without credit_decision" do
            application.credit_decision.destroy
            application.reload
            application.credit_decision.should be_nil
            expect{ application.save! }.to raise_error
          end  

          it "does not save without id_verified" do
            application.id_verified = nil
            expect{ application.save! }.to raise_error
          end  

          it "does not save with id_verified = false" do
            application.id_verified = false
            expect{ application.save! }.to raise_error
          end  

          it "does not save without initial_lease_choice" do
            application.initial_lease_choice = nil
            expect{ application.save! }.to raise_error
          end  

          it "does not save with invalid initial_lease_choice" do
            application.initial_lease_choice = 'other'
            expect{ application.save! }.to raise_error
          end  
        end
        
        context "with valid attributes" do
          it "saves successfully" do
            expect{ application = FactoryGirl.create(:finalized_application) }.to_not raise_error
          end
          
          it "is finalized?" do
            application.finalized?.should be_true
          end
        end
      end

      describe "completed" do
        let(:application) { FactoryGirl.create(:completed_application) }

        context "with invalid attributes" do
          it "does not save without store" do
            application.store = nil
            expect{ application.save! }.to raise_error
          end  

          it "does not save without customer" do
            application.customer = nil
            expect{ application.save! }.to raise_error
          end  

          it "does not save without matching_email" do
            application.matching_email = nil
            expect{ application.save! }.to raise_error
          end  

          it "does not save without time_at_address" do
            application.time_at_address = nil
            expect{ application.save! }.to raise_error
          end

          it "does not save without rent_or_own" do
            application.rent_or_own = nil
            expect{ application.save! }.to raise_error
          end

          it "does not save without rent_payment" do
            application.rent_payment = nil
            expect{ application.save! }.to raise_error
          end

          it "does not save without credit_decision" do
            application.credit_decision.destroy
            application.reload
            application.credit_decision.should be_nil
            expect{ application.save! }.to raise_error
          end  

          it "does not save without id_verified" do
            application.id_verified = nil
            expect{ application.save! }.to raise_error
          end  

          it "does not save with id_verified = false" do
            application.id_verified = false
            expect{ application.save! }.to raise_error
          end  

          it "does not save without initial_lease_choice" do
            application.initial_lease_choice = nil
            expect{ application.save! }.to raise_error
          end  

          it "does not save with invalid initial_lease_choice" do
            application.initial_lease_choice = 'other'
            expect{ application.save! }.to raise_error
          end  

          it "does not save without a lease" do
            application.lease.destroy
            application.reload
            application.lease.should be_nil
            expect{ application.save! }.to raise_error
          end  
        end
        
        context "with valid attributes" do
          it "saves successfully" do
            expect{ application = FactoryGirl.create(:completed_application) }.to_not raise_error
          end
          
          it "is finalized?" do
            application.completed?.should be_true
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
          unclaimed_1 = FactoryGirl.create(:unclaimed_application)
          unclaimed_2 = FactoryGirl.create(:unclaimed_application)
          claimed_1 = FactoryGirl.create(:claimed_application)
          
          applications = Application.unclaimed
          applications.should eq([unclaimed_1, unclaimed_2])
        end
      end      

      describe "self.claimed" do
        it "returns claimed applications" do
          unclaimed_1 = FactoryGirl.create(:unclaimed_application)
          claimed_1 = FactoryGirl.create(:claimed_application)
          claimed_2 = FactoryGirl.create(:claimed_application)
          
          applications = Application.claimed
          applications.should eq([claimed_1, claimed_2])
        end
      end

      describe "self.submitted" do
        it "returns submitted leases" do
          claimed_1 = FactoryGirl.create(:claimed_application)
          submitted_1 = FactoryGirl.create(:submitted_application)
          submitted_2 = FactoryGirl.create(:submitted_application)
          
          applications = Application.submitted
          applications.should eq([submitted_1, submitted_2])
        end
      end

      describe "self.denied" do
        it "returns denied leases" do
          approved_1 = FactoryGirl.create(:approved_application)
          denied_1 = FactoryGirl.create(:denied_application)
          denied_2 = FactoryGirl.create(:denied_application)
          
          applications = Application.denied
          applications.should eq([denied_1, denied_2])
        end
      end

      describe "self.approved" do
        it "returns approved leases" do
          submitted_1 = FactoryGirl.create(:submitted_application)
          approved_1 = FactoryGirl.create(:approved_application)
          approved_2 = FactoryGirl.create(:approved_application)
          
          applications = Application.approved
          applications.should eq([approved_1, approved_2])
        end
      end

      describe "self.finalized" do
        it "returns finalized leases" do
          approved_1 = FactoryGirl.create(:approved_application)
          finalized_1 = FactoryGirl.create(:finalized_application)
          finalized_2 = FactoryGirl.create(:finalized_application)
          
          applications = Application.finalized
          applications.should eq([finalized_1, finalized_2])
        end
      end

      describe "self.completed" do
        it "returns completed leases" do
          approved_1 = FactoryGirl.create(:approved_application)
          completed_1 = FactoryGirl.create(:completed_application)
          completed_2 = FactoryGirl.create(:completed_application)
          
          applications = Application.completed
          applications.should eq([completed_1, completed_2])
        end
      end
    end

    describe "instance methods", :instance_methods => true do
      describe "store_name" do
        let(:application) do
          store = FactoryGirl.create(:store, :name => "Demo Store")
          application = FactoryGirl.build(:unclaimed_application, :store_account_number => store.account_number)
        end

        it "returns store name" do
          application.store_name.should eq("Demo Store")
        end
      end

      describe "name" do
        let(:application) do
          store = FactoryGirl.create(:store, :name => "Demo Store")
          application = FactoryGirl.build(:unclaimed_application, :store_account_number => store.account_number, number_of_products: 2)
        end

        it "returns name and products" do
          application.name.should eq("Demo Store: Demo Product, Demo Product")
        end
      end

      describe "products_list" do
        let(:application) do
          application = FactoryGirl.build(:unclaimed_application, number_of_products: 2)
        end

        it "returns csv products list" do
          application.products_list.should eq("Demo Product, Demo Product")
        end
      end

      describe "products_total_price" do
        let(:application) do
          application = FactoryGirl.build(:unclaimed_application, number_of_products: 2)
        end

        it "returns total price of products" do
          application.products_total_price.should eq(BigDecimal.new("599.10"))
        end
      end
    end
  end
end
