require 'spec_helper'

describe TwilioService do
  # Service Initializer
  #----------------------------------------------------------------------------
  describe "AuthorizeNetService", :failing => true do
    let(:service) { TwilioService.new }
    
    it "gets account" do
      service.get_account.should_not be_nil
    end
  end

  # Methods
  #----------------------------------------------------------------------------
  describe "methods", :methods => true do
    let(:service) { TwilioService.new }

    describe "get_account" do
      it "is not null" do
        service.get_account.should_not be_nil
      end
    end

    describe "send_test_sms", :method => true do
      it "should return true" do
        service.send_test_sms.should be_true
      end
    end
  end
end