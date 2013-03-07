module FeatureMacros
  # Flash Message
  #----------------------------------------------------------------------------
  def no_flash
    page.should_not have_css("#flash-messages")
  end

  def flash_set(type, source, message)
    if (source == :devise)
      root = YAML.load_file("#{Rails.root}/config/locales/devise.en.yml")
    else
      root = YAML.load_file("#{Rails.root}/config/locales/en.yml")
    end

    message = root['en']['devise']['failure']['unauthenticated'] if (message == :unauthenticated)
    message = root['en']['devise']['failure']['unconfirmed'] if (message == :unconfirmed)
    message = root['en']['devise']['failure']['not_approved'] if (message == :unapproved)
    message = root['en']['devise']['failure']['invalid'] if (message == :invalid)
    message = root['en']['devise']['failure']['invalid_data'] if (message == :invalid_data)
    message = root['en']['devise']['failure']['authorize_net'] if (message == :authorize_net_error)
    message = root['en']['devise']['registrations']['signed_up_but_unconfirmed'] if (message == :needs_confirmation)
    message = root['en']['devise']['registrations']['signed_up_but_not_approved'] if (message == :needs_approval)
    message = root['en']['devise']['registrations']['updated'] if (message == :updated_registration)
    message = root['en']['devise']['registrations']['update_needs_confirmation'] if (message == :updated_registration_needs_confirmation)
    message = root['en']['devise']['sessions']['signed_in'] if (message == :signed_in)
    message = root['en']['devise']['sessions']['signed_out'] if (message == :signed_out)
    message = root['en']['devise']['passwords']['send_instructions'] if (message == :password_reset)
    message = root['en']['devise']['unlocks']['send_instructions'] if (message == :unlock_account)
    
    page.should have_css("#flash-messages")
    page.should have_css(".alert-#{type}")
    page.should have_content(message)
  end

  # Errors
  #----------------------------------------------------------------------------
  def has_error(source, message)
    if (source == :devise)
      root = YAML.load_file("#{Rails.root}/config/locales/devise.en.yml")
    if (source == :custom)
      root = nil
    end
    else
      root = YAML.load_file("#{Rails.root}/config/locales/en.yml")
    end

    message = root['en']['errors']['messages']['not_locked'] if (message == :not_locked)
    message = root['en']['errors']['messages']['not_found'] if (message == :not_found)
    message = "doesn't match confirmation" if (message == :confirmation_mismatch)
    message = "already been taken" if (message == :taken)
    message = "can't be blank" if (message == :blank)
    
    page.should have_css(".error")
    page.should have_content(message)
  end



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

  def confirmation_email_sent_to(address, token)
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
  def admin_email_alert
    found_email = false
    ActionMailer::Base.deliveries.each do |email|
      if (email.to == ["bryce.senz@credda.com"])
        found_email = true
        email.to.should eq(["bryce.senz@credda.com"])
      end
    end
    found_email.should be_true
  end
  
  # APIs
  #----------------------------------------------------------------------------
  def no_authorize_net_request
    a_request(:post, /https:\/\/apitest.authorize.net\/xml\/v1\/request.api.*/).should_not have_been_made
  end

  def made_authorize_net_request(request)
    a_request(:post, /https:\/\/apitest.authorize.net\/xml\/v1\/request.api.*/).with(:body => /.*#{request}.*/).should have_been_made
  end

  def made_google_api_request
    a_request(:get, /http:\/\/maps.googleapis.com\/maps\/api\/geocode\/json?.*/).should have_been_made.times(2)
  end
end