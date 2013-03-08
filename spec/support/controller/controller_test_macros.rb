module ControllerTestMacros
  # Emails
  #----------------------------------------------------------------------------
  def no_email_sent
    email = last_email 
    email.should be_nil
  end

  def unapproved_email_sent_to(address)
    found_email = false
    ActionMailer::Base.deliveries.each do |email|
      if (email.to == [address])
        found_email = true
        email.to.should eq([address])
        email.body.should match(/administrator approval/)
      end
    end
    found_email.should be_true
  end

  def confirmation_email_sent_to?(address)
    found_email = false
    ActionMailer::Base.deliveries.each do |email|
      if (email.to == [address])
        found_email = true
        email.to.should eq([address])        
        email.body.should match(/Confirm my account/)
      end
    end
    return found_email
  end

  def password_reset_email_sent_to(address, token)
    found_email = false
    ActionMailer::Base.deliveries.each do |email|
      if (email.to == [address])
        found_email = true
        email.to.should eq([address])
        email.body.should match(/#{token}/)
      end
    end
    found_email.should be_true
  end

  def unlock_email_sent_to(address, token)
    found_email = false
    ActionMailer::Base.deliveries.each do |email|
      if (email.to == [address])
        found_email = true
        email.to.should eq([address])
        email.from.should eq(["no-reply@credda.com"])
        subject = YAML.load_file("#{Rails.root}/config/locales/devise.en.yml")['en']['devise']['mailer']['unlock_instructions']['subject']
        email.subject.should eq(subject)
        email.body.should match(/#{token}/)
      end
    end
    found_email.should be_true
  end

  # Admin Alerts
  #----------------------------------------------------------------------------
  def admin_email_alert?
    found_email = false
    ActionMailer::Base.deliveries.each do |email|
      if (email.to == ["bryce.senz@credda.com"])
        found_email = true
        email.to.should eq(["bryce.senz@credda.com"])
      end
    end
    return found_email
  end
end