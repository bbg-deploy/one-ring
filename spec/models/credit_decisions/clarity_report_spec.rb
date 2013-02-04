require 'spec_helper'

describe ClarityReport do
  # Model & Factory Validation
  #----------------------------------------------------------------------------
  describe "factory validation", :factory_validation => true do
    specify { ClarityReport.new.should be_an_instance_of(ClarityReport) }
    specify { FactoryGirl.create(:clarity_report).should be_valid }
  end

  # Associations
  #----------------------------------------------------------------------------
  describe "associations", :associations => true do
    describe "credit_decision" do
      it_behaves_like "required belongs_to", :clarity_report, :credit_decision
      it_behaves_like "immutable belongs_to", :clarity_report, :credit_decision
      it_behaves_like "immutable belongs_to", :clarity_report, :credit_decision
    end
  end

  # Attributes
  #----------------------------------------------------------------------------
  describe "attributes", :attributes => true do
    describe "model_score" do
      it_behaves_like "attr_accessible", :clarity_report, :model_score,
        [0.00, 11.28, 50.43, 100.00],  #Valid values
        [nil, -0.01, 100.01, 200, "ten"] #Invalid values      
    end
  end

  # Behavior
  #----------------------------------------------------------------------------
  describe "behavior", :behavior => true do
  end
end