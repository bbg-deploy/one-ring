module ClaimableSharedExamples
  shared_examples_for "claimable attributes" do |factory|
    describe "matching_email" do
      it_behaves_like "attr_accessible", factory, :matching_email,
        ["something@notcredda.com"], #Valid values
        [nil, "something.notcredda.com", "something@credda.com"] #Invalid values
    end    
  end

  shared_examples_for "claimable behavior" do |factory|
    describe "claim_contract" do
      context "without customer" do
        let(:model) { FactoryGirl.create(factory, :customer => nil)}
        let(:customer) { FactoryGirl.create(:customer) }
        
        it "assigns customer if originally nil", :failing => true do
          model.claim_contract(customer)
          model.reload
          model.customer.should_not be_nil
          model.customer.should eq(customer)
        end
      end

      context "with customer" do
        let(:model) { FactoryGirl.create(factory)}
        let(:customer) { FactoryGirl.create(:customer) }
        
        it "does not assign new customer" do
          model.claim_contract(customer)
          model.reload
          model.customer.should_not eq(customer)
        end
      end
    end

    describe "claimed?" do
      context "without customer" do
        let(:model) { FactoryGirl.create(factory, :customer => nil)}
        
        it "returns false" do
          model.claimed?.should be_false
        end
      end

      context "with customer" do
        let(:model) { FactoryGirl.create(factory)}
        
        it "returns true" do
          model.claimed?.should be_true
        end
      end
    end

    describe "class methods" do
      describe "self.unclaimed_contracts" do
        let(:claimed_1) { FactoryGirl.create(factory) }
        let(:claimed_2) { FactoryGirl.create(factory) }
        let(:unclaimed_1) { FactoryGirl.create(factory, :customer => nil) }
        let(:unclaimed_2) { FactoryGirl.create(factory, :customer => nil) }
        before(:each) do
          claimed_1.reload
          claimed_2.reload
          unclaimed_1.reload
          unclaimed_2.reload
        end
  
        it "returns correct count" do
          klass = claimed_1.class
          klass.unclaimed_contracts.count.should eq(2)  
        end
  
        it "returns correct contracts" do
          klass = claimed_1.class
          klass.unclaimed_contracts.should eq([unclaimed_1, unclaimed_2])
        end      
      end    
    end    
  end
end