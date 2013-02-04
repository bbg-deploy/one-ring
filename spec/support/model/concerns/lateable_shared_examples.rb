module LateableSharedExamples
  shared_examples_for "is_lateable attributes" do |factory|
    describe "due_date" do
      it_behaves_like "attr_accessible", factory, :due_date,
        [1.day.ago, 3.days.ago, 14.days.from_now], #Valid values
        [nil] #Invalid values
    end
  end

  shared_examples_for "is_lateable state_machine" do |factory|
    puts "time_state machine has no tests written (line 138 of transaction_shared_examples.rb)"
    describe "initial conditions" do
      let(:transaction) { FactoryGirl.create(factory) }
      
      it "should have state 'on_time'" do
        transaction.save!
        transaction.on_time?.should be_true        
      end
    end

    describe "events", :events => true do
      describe "mark_as_past_due" do
        context "as 'on_time'" do
        end
        context "as 'past_due" do
        end
      end
    end
    describe "transitions", :transitions => true do
    end
  end
end