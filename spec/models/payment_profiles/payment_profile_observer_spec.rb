require 'spec_helper'

describe PaymentProfileObserver, :observer => true do
  # Before Create
  #----------------------------------------------------------------------------
  describe "before_create", :before_create => true do
    context "without cim_customer_payment_profile_id" do
      before :each do
        @payment_profile = FactoryGirl.build_stubbed(:payment_profile_no_id)
        @observer = PaymentProfileObserver.instance
      end
      
      it "should invoke after_save on the observed object", :failing => true do
        @payment_profile.should_receive(:set_cim_customer_payment_profile_id)
        @observer.before_create(@payment_profile)
      end
    end

    context "without cim_customer_payment_profile_id" do
      before :each do
        @payment_profile = FactoryGirl.build_stubbed(:payment_profile)
        @observer = PaymentProfileObserver.instance
      end
      
      it "should invoke after_save on the observed object" do
        @payment_profile.should_not_receive(:set_cim_customer_payment_profile_id)
        @observer.before_create(@payment_profile)
      end
    end

=begin
    context "without cim_customer_profile_id" do
      let(:customer) { FactoryGirl.build(:customer_no_id) }

      it "sends createCustomerProfileRequest" do
        Customer.observers.enable :customer_observer do
          customer.save
          a_request(:post, /https:\/\/apitest.authorize.net\/xml\/v1\/request.api.*/).with(:body => /.*createCustomerProfileRequest.*/).should have_been_made
        end
      end
  
      it "does not send updateCustomerProfileRequest" do
        Customer.observers.enable :customer_observer do
          customer.save
          a_request(:post, /https:\/\/apitest.authorize.net\/xml\/v1\/request.api.*/).with(:body => /.*updateCustomerProfileRequest.*/).should_not have_been_made
        end
      end
    end

    context "with cim_customer_profile_id" do
      let(:customer) { FactoryGirl.build(:customer) }

      it "does not send createCustomerProfileRequest" do
        Customer.observers.enable :customer_observer do
          customer.save
          a_request(:post, /https:\/\/apitest.authorize.net\/xml\/v1\/request.api.*/).with(:body => /.*createCustomerProfileRequest.*/).should_not have_been_made
        end
      end
  
      it "does not send updateCustomerProfileRequest" do
        Customer.observers.enable :customer_observer do
          customer.save
          a_request(:post, /https:\/\/apitest.authorize.net\/xml\/v1\/request.api.*/).with(:body => /.*updateCustomerProfileRequest.*/).should_not have_been_made
        end
      end
    end
=end
  end

  # Before Update
  #----------------------------------------------------------------------------
  describe "before_update", :before_update => true do
=begin
    context "without cim_customer_profile_id" do
      let(:customer) { FactoryGirl.build(:customer_no_id) }

      it "sends createCustomerProfileRequest" do
        Customer.observers.enable :customer_observer do
          customer.cim_customer_profile_id.should be_nil
          customer.update_attributes({:first_name => "Bob"})
          a_request(:post, /https:\/\/apitest.authorize.net\/xml\/v1\/request.api.*/).with(:body => /.*createCustomerProfileRequest.*/).should have_been_made
        end
      end
  
      it "does not send updateCustomerProfileRequest" do
        Customer.observers.enable :customer_observer do
          customer.cim_customer_profile_id.should be_nil
          customer.update_attributes({:first_name => "Bob"})
          a_request(:post, /https:\/\/apitest.authorize.net\/xml\/v1\/request.api.*/).with(:body => /.*updateCustomerProfileRequest.*/).should_not have_been_made
        end
      end
    end

    context "with cim_customer_profile_id" do
      let(:customer) { FactoryGirl.create(:customer) }

      it "does not send createCustomerProfileRequest" do
        Customer.observers.enable :customer_observer do
          customer.update_attributes({:first_name => "Bob"})
          a_request(:post, /https:\/\/apitest.authorize.net\/xml\/v1\/request.api.*/).with(:body => /.*createCustomerProfileRequest.*/).should_not have_been_made
        end
      end
  
      it "sends updateCustomerProfileRequest" do
        Customer.observers.enable :customer_observer do
          customer.update_attributes({:first_name => "Bob"})
          a_request(:post, /https:\/\/apitest.authorize.net\/xml\/v1\/request.api.*/).with(:body => /.*updateCustomerProfileRequest.*/).should have_been_made
        end
      end
    end
=end
  end

  # Before Destroy
  #----------------------------------------------------------------------------
  describe "before_destroy", :before_destroy => true do
=begin
    context "without cim_customer_profile_id" do
      let(:customer) { FactoryGirl.build(:customer_no_id) }

      it "sends createCustomerProfileRequest" do
        Customer.observers.enable :customer_observer do
          customer.cim_customer_profile_id.should be_nil
          customer.destroy
          a_request(:post, /https:\/\/apitest.authorize.net\/xml\/v1\/request.api.*/).with(:body => /.*deleteCustomerProfileRequest.*/).should_not have_been_made
        end
      end
    end

    context "with cim_customer_profile_id" do
      let(:customer) { FactoryGirl.create(:customer) }

      it "does not send createCustomerProfileRequest" do
        Customer.observers.enable :customer_observer do
          customer.destroy
          a_request(:post, /https:\/\/apitest.authorize.net\/xml\/v1\/request.api.*/).with(:body => /.*deleteCustomerProfileRequest.*/).should have_been_made
        end
      end  
    end
=end
  end
end