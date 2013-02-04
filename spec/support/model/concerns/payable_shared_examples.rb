module PayableSharedExamples
  shared_examples_for "payable attributes" do |factory|
    describe "principal_total" do
      it_behaves_like "attr_protected", factory, :principal_total,
        [100, 1, 25.50], #Valid values
        [nil, 0, -1, "x"] #Invalid values
    end

    describe "principal_balance" do
      it_behaves_like "attr_protected", factory, :principal_balance,
        [100, 0, 1, 25.50], #Valid values
        [nil, -1, "x"] #Invalid values
    end

    describe "balance" do
      it_behaves_like "attr_protected", factory, :balance,
        [100, 0, 1, 25.50], #Valid values
        [nil, -1, "x"] #Invalid values
    end

    describe "markup" do
      it_behaves_like "attr_protected", factory, :markup,
        [1.01, 2.05, 2.2, 25.50], #Valid values
        [nil, -1, "x", 1.0] #Invalid values
    end

    describe "number_of_payments" do
      it_behaves_like "attr_protected", factory, :number_of_payments,
        [1, 2, 13, 25], #Valid values
        [nil, -1, "x"] #Invalid values
        
      it "drops decimals down to integers" do
        lease = FactoryGirl.create(factory)
        lease.update_attribute(:number_of_payments, 2.9)
        lease.should be_valid
        lease.number_of_payments.should eq(2)
      end
    end
  end

end