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
        notification_email.to.should eq(["admin@credda.com"])
      end
    end

    it "should have sent email with user's username" do
      Store.observers.enable :store_observer do
        store = FactoryGirl.create(:store)
        notification_email = ActionMailer::Base.deliveries.last
        notification_email.body.should match(/#{store.username}/)
      end
    end
  end
end