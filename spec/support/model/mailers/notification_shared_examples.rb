module NotificationSharedExamples
  # CRUD Triggers
  #----------------------------------------------------------------------------
  shared_examples_for "sends notification on create (successful create)" do |factory, notification_mailer|
    it "delivers notification" do
      mailer = mock
      mailer.should_receive(:deliver)
      notification_mailer.should_receive(:report_error).and_return(mailer)
      object = FactoryGirl.create(factory)
    end
  end

  shared_examples_for "sends notification on create (failed create)" do |factory, notification_mailer|
    it "delivers notification" do
      mailer = mock
      mailer.should_receive(:deliver)
      notification_mailer.should_receive(:report_error).and_return(mailer)
      expect{ object = FactoryGirl.create(factory) }.to raise_error
    end
  end

  shared_examples_for "no notification on create (successful create)" do |factory, notification_mailer|
    it "does not receive notification" do
      notification_mailer.should_not_receive(:report_error)
      object = FactoryGirl.create(factory)
    end
  end

  shared_examples_for "no notification on create (failed create)" do |factory, notification_mailer|
    it "does not receive notification" do
      notification_mailer.should_not_receive(:report_error)
      expect {object = FactoryGirl.create(factory) }.to raise_error
    end
  end

  shared_examples_for "sends notification on destroy" do |factory, notification_mailer|
    let(:object) { FactoryGirl.create(factory) }
    it "delivers notification" do
      object.reload
      mailer = mock
      mailer.should_receive(:deliver)
      notification_mailer.should_receive(:report_error).and_return(mailer)
      object.destroy
    end
  end

  shared_examples_for "no notification on destroy" do |factory, notification_mailer|
    let(:object) { FactoryGirl.create(factory) }
    it "does not receive notification" do
      object.reload
      notification_mailer.should_not_receive(:report_error)
      object.destroy
    end
  end      
end