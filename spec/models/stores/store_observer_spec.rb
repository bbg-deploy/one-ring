require 'spec_helper'

describe StoreObserver, :observer => true do
  # After Create
  #----------------------------------------------------------------------------
  describe "after_create", :after_create => true do
    it "should email Administrator" do
      Store.observers.enable :store_observer do
        mailer = mock
        mailer.should_receive(:deliver)
        AdminNotificationMailer.should_receive(:new_user).and_return(mailer)
        store = FactoryGirl.create(:store)
      end
    end

    it "should have sent email to admin" do
      Store.observers.enable :store_observer do
        store = FactoryGirl.create(:store)
        notification_email = ActionMailer::Base.deliveries.last
        notification_email.to.should eq(["bryce.senz@credda.com"])
      end
    end

    it "should have sent email with New user subject" do
      Store.observers.enable :store_observer do
        store = FactoryGirl.create(:store)
        notification_email = ActionMailer::Base.deliveries.last
        notification_email.subject.should eq("You have a new user!")
      end
    end
  end
end