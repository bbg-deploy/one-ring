require 'spec_helper'

describe CustomerObserver, :observer => true do
  # Before Create
  #----------------------------------------------------------------------------
  describe "before_create", :before_create => true do
    context "without cim_customer_profile_id" do
      let(:customer) { FactoryGirl.build(:customer_no_id) }

      context "with successful Authorize.net response" do
        before(:each) do
          webmock_authorize_net("createCustomerProfileRequest", :I00001)
        end

        it "sends createCustomerProfileRequest" do
          Customer.observers.enable :customer_observer do
            customer.save
            a_request(:post, /https:\/\/apitest.authorize.net\/xml\/v1\/request.api.*/).with(:body => /.*createCustomerProfileRequest.*/).should have_been_made
          end
        end

        it "saves customer successfully" do
          Customer.observers.enable :customer_observer do
            customer.save.should be_true
          end
        end
      end

      context "with unsuccessful Authorize.net response" do
        before(:each) do
          webmock_authorize_net("createCustomerProfileRequest", :E00001)
        end

        it "sends createCustomerProfileRequest" do
          Customer.observers.enable :customer_observer do
            customer.save
            a_request(:post, /https:\/\/apitest.authorize.net\/xml\/v1\/request.api.*/).with(:body => /.*createCustomerProfileRequest.*/).should have_been_made
          end
        end
    
        it "prevents customer persistence" do
          Customer.observers.enable :customer_observer do
            customer.save.should be_false
          end
        end

        it "send AdminNotifier email" do
          Customer.observers.enable :customer_observer do
            customer.save
            last_email.to.should eq(["bryce.senz@credda.com"])
            last_email.subject.should eq("Authorize.net Error")
          end
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
    end
  end

  # Before Update
  #----------------------------------------------------------------------------
  describe "before_update", :before_update => true do
    context "without cim_customer_profile_id" do
      let(:customer) { FactoryGirl.build(:customer_no_id) }

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

      context "with successful Authorize.net response" do
        before(:each) do
          webmock_authorize_net("updateCustomerProfileRequest", :I00001)
        end
  
        it "sends updateCustomerProfileRequest" do
          Customer.observers.enable :customer_observer do
            customer.update_attributes({:first_name => "Bob"})
            a_request(:post, /https:\/\/apitest.authorize.net\/xml\/v1\/request.api.*/).with(:body => /.*updateCustomerProfileRequest.*/).should have_been_made
          end
        end

        it "updates customer successfully" do
          Customer.observers.enable :customer_observer do
            customer.update_attributes({:first_name => "Bob"}).should be_true
          end
        end
      end

      context "with unsuccessful Authorize.net response" do
        before(:each) do
          webmock_authorize_net("updateCustomerProfileRequest", :e00001)
        end
  
        it "sends updateCustomerProfileRequest" do
          Customer.observers.enable :customer_observer do
            customer.update_attributes({:first_name => "Bob"})
            a_request(:post, /https:\/\/apitest.authorize.net\/xml\/v1\/request.api.*/).with(:body => /.*updateCustomerProfileRequest.*/).should have_been_made
          end
        end

        it "prevents customer update" do
          Customer.observers.enable :customer_observer do
            customer.update_attributes({:first_name => "Bob"}).should be_false
          end
        end

        it "send AdminNotifier email" do
          Customer.observers.enable :customer_observer do
            customer.update_attributes({:first_name => "Bob"})
            last_email.to.should eq(["bryce.senz@credda.com"])
            last_email.subject.should eq("Authorize.net Error")
          end
        end
      end
    end
  end

  # Before Destroy
  #----------------------------------------------------------------------------
  describe "before_destroy", :before_destroy => true do
    context "without cim_customer_profile_id" do
      let(:customer) { FactoryGirl.create(:customer_no_id) }

      context "with deletable object" do
        before(:each) { customer.stub(:deletable?).and_return(true) }
        
        it "does not send deleteCustomerProfileRequest" do
          Customer.observers.enable :customer_observer do
            customer.cim_customer_profile_id.should be_nil
            customer.destroy
            a_request(:post, /https:\/\/apitest.authorize.net\/xml\/v1\/request.api.*/).with(:body => /.*deleteCustomerProfileRequest.*/).should_not have_been_made
          end
        end
        
        it "does not persist the object" do
          Customer.observers.enable :customer_observer do
            customer.destroy
            expect { customer.reload }.to raise_error
          end
        end
      end
      
      context "with non-deletable object" do
        before(:each) { customer.stub(:deletable?).and_return(false) }
        
        it "does not send deleteCustomerProfileRequest" do
          Customer.observers.enable :customer_observer do
            customer.cim_customer_profile_id.should be_nil
            customer.destroy
            a_request(:post, /https:\/\/apitest.authorize.net\/xml\/v1\/request.api.*/).with(:body => /.*deleteCustomerProfileRequest.*/).should_not have_been_made
          end
        end

        it "persists the object" do
          Customer.observers.enable :customer_observer do
            customer.deletable?.should be_false
            customer.destroy
            expect { customer.reload }.to_not raise_error
          end
        end
      end
    end

    context "with cim_customer_profile_id" do
      let(:customer) { FactoryGirl.create(:customer) }

      context "with deletable object" do
        before(:each) { customer.stub(:deletable?).and_return(true) }

        context "with successful Authorize.net response" do
          before(:each) do
            webmock_authorize_net("createCustomerProfileRequest", :I00001)
          end
  
          it "sends deleteCustomerProfileRequest" do
            Customer.observers.enable :customer_observer do
              customer.destroy
              a_request(:post, /https:\/\/apitest.authorize.net\/xml\/v1\/request.api.*/).with(:body => /.*deleteCustomerProfileRequest.*/).should have_been_made
            end
          end
  
          it "destroys customer successfully" do
            Customer.observers.enable :customer_observer do
              customer.destroy.should be_true
            end
          end

          it "does not persist object in the database" do
            Customer.observers.enable :customer_observer do              
              customer.destroy
              expect { customer.reload }.to raise_error
            end
          end
        end

        context "with unsuccessful Authorize.net response" do
          before(:each) do
            webmock_authorize_net("deleteCustomerProfileRequest", :E00001)
          end
  
          it "sends deleteCustomerProfileRequest" do
            Customer.observers.enable :customer_observer do
              customer.destroy
              a_request(:post, /https:\/\/apitest.authorize.net\/xml\/v1\/request.api.*/).with(:body => /.*deleteCustomerProfileRequest.*/).should have_been_made
            end
          end
  
          it "does not destroy customer" do
            Customer.observers.enable :customer_observer do
              customer.destroy.should be_false
            end
          end
  
          it "persists object in database" do
            Customer.observers.enable :customer_observer do
              customer.destroy
              expect { customer.reload }.to_not raise_error
            end
          end

          it "send AdminNotifier email" do
            Customer.observers.enable :customer_observer do
              customer.destroy
              last_email.to.should eq(["bryce.senz@credda.com"])
              last_email.subject.should eq("Authorize.net Error")
            end
          end
        end
      end
    end
  end

  # After Create
  #----------------------------------------------------------------------------
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
end