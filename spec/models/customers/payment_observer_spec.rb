require 'spec_helper'

describe PaymentObserver, :observer => true do
  # Before Create
  #----------------------------------------------------------------------------
  describe "before_create", :before_create => true do
    let(:payment) { FactoryGirl.build(:payment) }

    context "with successful Authorize.net response" do
      before(:each) do
        webmock_authorize_net("createCustomerProfileTransactionRequest", :I00001)
      end

      it "sends createCustomerProfileRequest" do
        Payment.observers.enable :payment_observer do
          payment.save
          a_request(:post, /https:\/\/apitest.authorize.net\/xml\/v1\/request.api.*/).with(:body => /.*createCustomerProfileTransactionRequest.*/).should have_been_made
        end
      end

      it "saves payment successfully" do
        Payment.observers.enable :payment_observer do
          payment.save.should be_true
        end
      end
    end

    context "with unsuccessful Authorize.net response" do
      before(:each) do
        webmock_authorize_net("createCustomerProfileTransactionRequest", :E00001)
      end

      it "sends createCustomerProfileTransactionRequest" do
        Payment.observers.enable :payment_observer do
          payment.save
          a_request(:post, /https:\/\/apitest.authorize.net\/xml\/v1\/request.api.*/).with(:body => /.*createCustomerProfileTransactionRequest.*/).should have_been_made
        end
      end
  
      it "prevents payment persistence" do
        Payment.observers.enable :payment_observer do
          payment.save.should be_false
        end
      end

      it "send AdminNotifier email" do
        Payment.observers.enable :payment_observer do
          payment.save
          last_email.to.should eq(["bryce.senz@credda.com"])
          last_email.subject.should eq("Authorize.net Error")
        end
      end
    end
  end

  # After Create
  #----------------------------------------------------------------------------
=begin
  describe "after_create", :after_create => true do
    it "should email Administrator" do
      Customer.observers.enable :customer_observer do
        mailer = mock
        mailer.should_receive(:deliver)
        AdminNotificationMailer.should_receive(:new_user).and_return(mailer)
        customer = FactoryGirl.create(:customer)
      end
    end

    it "should have sent email to admin" do
      Customer.observers.enable :customer_observer do
        customer = FactoryGirl.create(:customer)
        notification_email = ActionMailer::Base.deliveries.last
        notification_email.to.should eq(["bryce.senz@credda.com"])
      end
    end

    it "should have sent email with correct subject" do
      Customer.observers.enable :customer_observer do
        customer = FactoryGirl.create(:customer)
        notification_email = ActionMailer::Base.deliveries.last
        notification_email.subject.should eq("You have a new user!")
      end
    end
  end
=end
end