require 'spec_helper'

describe PaymentProfileObserver, :observer => true do
  # Before Create
  #----------------------------------------------------------------------------
  describe "before_create", :before_create => true do
    context "without cim_customer_payment_profile_id" do
      let(:payment_profile) { FactoryGirl.build(:payment_profile_no_id) }
      let(:observer) { PaymentProfileObserver.instance }

      it "set cim_customer_payment_profile_id before create" do
        payment_profile.should_receive(:set_cim_customer_payment_profile_id)
        observer.before_create(payment_profile)
      end

      it "sends createCustomerPaymentProfileRequest" do
        PaymentProfile.observers.enable :payment_profile_observer do
          payment_profile.save
          a_request(:post, /https:\/\/apitest.authorize.net\/xml\/v1\/request.api.*/).with(:body => /.*createCustomerPaymentProfileRequest.*/).should have_been_made
        end
      end
    end

    context "with cim_customer_payment_profile_id" do
      let(:payment_profile) { FactoryGirl.build(:payment_profile) }
      let(:observer) { PaymentProfileObserver.instance }
      
      it "does not set cim_customer_payment_profile_id before create" do
        payment_profile.should_not_receive(:set_cim_customer_payment_profile_id)
        observer.before_create(payment_profile)
      end

      it "does not send createCustomerPaymentProfileRequest" do
        PaymentProfile.observers.enable :payment_profile_observer do
          payment_profile.save
          a_request(:post, /https:\/\/apitest.authorize.net\/xml\/v1\/request.api.*/).with(:body => /.*createCustomerPaymentProfileRequest.*/).should_not have_been_made
        end
      end
    end
  end

  # Before Update
  #----------------------------------------------------------------------------
  describe "before_update", :before_update => true do
    context "with cim_customer_payment_profile" do
      let(:payment_profile) { FactoryGirl.create(:payment_profile) }
      let(:observer) { PaymentProfileObserver.instance }

      it "sends updateCustomerPaymentProfileRequest" do
        PaymentProfile.observers.enable :payment_profile_observer do
          payment_profile.update_attributes( {:first_name => "Bob"} )
          a_request(:post, /https:\/\/apitest.authorize.net\/xml\/v1\/request.api.*/).with(:body => /.*updateCustomerPaymentProfileRequest.*/).should have_been_made
        end
      end
    end
  end

  # Before Destroy
  #----------------------------------------------------------------------------
  describe "before_destroy", :before_destroy => true do
    context "with cim_customer_payment_profile" do
      let(:payment_profile) { FactoryGirl.create(:payment_profile) }
      let(:observer) { PaymentProfileObserver.instance }

      it "sends updateCustomerPaymentProfileRequest" do
        PaymentProfile.observers.enable :payment_profile_observer do
          payment_profile.destroy
          a_request(:post, /https:\/\/apitest.authorize.net\/xml\/v1\/request.api.*/).with(:body => /.*deleteCustomerPaymentProfileRequest.*/).should have_been_made
        end
      end
    end
  end
end