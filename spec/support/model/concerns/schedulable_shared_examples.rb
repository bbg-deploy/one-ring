module SchedulableSharedExamples
  shared_examples_for "schedulable attributes" do |factory|
    describe "payment_frequency" do
      it_behaves_like "attr_accessible", factory, :payment_frequency,
        [:weekly, :biweekly, :semimonthly, :monthly],  #Valid values
        [nil, "notatime", "daily"] #Invalid values      
    end
  end

end