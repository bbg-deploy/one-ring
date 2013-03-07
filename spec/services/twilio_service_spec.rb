require 'spec_helper'

describe TwilioService do
  AUTHORIZE_NET_SUCCESS_CODES =           [:I00001]
  AUTHORIZE_NET_PROCESSING_ERROR_CODES =  [:E00001]
  AUTHORIZE_NET_REQUEST_ERROR_CODES =     [:E00002, :E00003, :E00004, :E00005, :E00006, 
                                           :E00007, :E00008, :E00009, :E00010, :E00011,
                                           :E00044, :E00045, :E00051]
  AUTHORIZE_NET_DATA_ERROR_CODES =        [:E00013, :E00014, :E00015, :E00016, :E00019, 
                                           :E00029, :E00039, :E00040, :E00041, :E00042, 
                                           :E00043]
  AUTHORIZE_NET_TRANSACTION_ERROR_CODES = [:E00027]

  # Service Initializer
  #----------------------------------------------------------------------------
  describe "initialize" do
    it "should not be nil" do
      service = TwilioService.new
      service.should_not be_nil
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

    describe "send_test_sms" do
      it "should return true" do
        service.send_test_sms.should be_true
      end
    end
  end
end