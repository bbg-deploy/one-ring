module ModelSharedExamples
  # Objects & Errors
  #----------------------------------------------------------------------------
  shared_examples_for "valid record" do |factory|
    describe "on build", :build => true do
      it "builds valid object" do
        object = FactoryGirl.build(factory).should be_valid
      end
    end      

    describe "on create", :create => true do
      it "creates valid record" do
        expect { FactoryGirl.create(factory) }.to_not raise_error
      end

      it "creates persistent record" do
        object = FactoryGirl.create(factory)
        expect{ object.reload }.to_not raise_error
      end
    end
  end

  shared_examples_for "invalid record" do |factory|
    describe "on build", :build => true do
      it "builds valid object" do
        object = FactoryGirl.build(factory).should_not be_valid
      end
    end      

    describe "on create", :create => true do
      it "creates valid record" do
        expect { FactoryGirl.create(factory) }.to raise_error
      end
    end
  end
end