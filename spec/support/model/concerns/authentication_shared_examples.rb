module AuthenticationSharedExamples
  shared_examples_for "devise authenticatable" do |factory|
    let(:user) do
      user = FactoryGirl.build(factory)
      user.confirm!
      user.reload
    end
    let(:user_class) { user.class }

    before(:all) do
      # Authentication Configuration
      authentication_keys ||= [:login]
    end
    
    describe "finding authentication keys" do
      it "should be valid for authentication" do
        user.valid_for_authentication?.should be_true
      end

      it "authenticates with email" do
        if (authentication_keys.include? :email)
          user_class.find_for_database_authentication( { :email => user.email.downcase } ).should eq(user)
          user_class.find_for_database_authentication( { :email => user.email.upcase } ).should eq(user)
        end
      end
      
      it "authenticates with username" do
        if (authentication_keys.include? :username)
          user_class.find_for_database_authentication( { :username => user.username.downcase } ).should eq(user)
          user_class.find_for_database_authentication( { :username => user.username.upcase } ).should eq(user)
        end
      end
      
      it "authenticates with login" do
        if (authentication_keys.include? :login)
          user_class.find_for_database_authentication( { :login => user.email.downcase } ).should eq(user)
          user_class.find_for_database_authentication( { :login => user.email.upcase } ).should eq(user)
          user_class.find_for_database_authentication( { :login => user.username.downcase } ).should eq(user)
          user_class.find_for_database_authentication( { :login => user.username.upcase } ).should eq(user)
        end
      end
    end

    describe "validating password" do
      it "should return true for valid password" do
        user.valid_password?(user.password).should be_true
      end

      it "should return false for valid password" do
        user.valid_password?("badpassword").should be_false
      end
    end
  end

  shared_examples_for "devise recoverable" do |factory|
    let(:user) do
      user = FactoryGirl.build(factory)
      user.confirm!
      user.reload
    end
    let(:recovery_email) do
      user.send_reset_password_instructions
      recovery_email = ActionMailer::Base.deliveries.last
    end
    let(:user_class) { user.class }

    before(:all) do
      # Recoverable Configuration
      reset_password_keys ||= [:email]
      reset_password_within ||= 6.hours
    end
      
    describe "sending recovery email" do
      it "sends email to user" do
        recovery_email.to.should eq([user.email])
      end
      
      it "sends email from 'no-reply@credda.com'" do
        recovery_email.from.should eq(["no-reply@credda.com"])
      end

      it "sends email with recovery subject line" do
        subject = YAML.load_file("#{Rails.root}/config/locales/devise.en.yml")['en']['devise']['mailer']['reset_password_instructions']['subject']
        recovery_email.subject.should eq(subject)
      end
      
      it "sends email with the correct key" do
        recovery_email.body.should match(/#{user.reset_password_token}/)
      end
    end
    
    describe "finding user via with reset keys" do
      it "can recover using email key" do
        if (reset_password_keys.include? :email)
          reset_password_user = user_class.send_reset_password_instructions(:email => user.email)
          reset_password_user.should eq(user)
        end
      end
      
      it "can recover using username key" do
        if (reset_password_keys.include? :username)
          reset_password_user = user_class.send_reset_password_instructions(:username => user.username)
          reset_password_user.should eq(user)
        end
      end
      
      it "can recover using login key" do
        if (reset_password_keys.include? :login)
          reset_password_user = user_class.send_reset_password_instructions(:login => user.email)
          reset_password_user.should eq(user)
          reset_password_user = user_class.send_reset_password_instructions(:login => user.username)
          reset_password_user.should eq(user)
        end
      end
    end

    describe "handling time limit" do
      context "before password reset expiry time" do        
        it "is within password recovery period" do
          user.update_attribute(:reset_password_sent_at, (reset_password_within - 5.minutes).ago.utc)
          user.reset_password_period_valid?.should be_true
        end
      end

      context "after password reset expiry time" do
        it "is within password recovery period" do
          user.update_attribute(:reset_password_sent_at, (reset_password_within + 5.minutes).ago.utc)
          user.reset_password_period_valid?.should be_false
        end
      end
    end
  end

  shared_examples_for "devise lockable" do |factory|
    let(:user) do
      user = FactoryGirl.build(factory)
      user.confirm!
      user.lock_access!
      user.reload
    end
    let(:unlock_email) do
      user.send_unlock_instructions
      unlock_email = ActionMailer::Base.deliveries.last
    end

    before(:all) do
      # Lockable Configuration
      unlock_keys ||= [:email]
      unlock_strategy ||= [:both]
      maximum_attempts ||= 10
      unlock_in ||= 1.hour
    end

    describe "sending unlock email" do
      it "sends email to user" do
        unlock_email.to.should eq([user.email])
      end
      
      it "sends email from 'no-reply@credda.com'" do
        unlock_email.from.should eq(["no-reply@credda.com"])
      end

      it "sends email with recovery subject line" do
        subject = YAML.load_file("#{Rails.root}/config/locales/devise.en.yml")['en']['devise']['mailer']['unlock_instructions']['subject']
        unlock_email.subject.should eq(subject)
      end
      
      it "sends email with the correct key" do
        unlock_email.body.should match(/#{user.unlock_token}/)
      end
    end

    describe "finding user via unlock keys" do
      it "finds user using email key" do
        if (unlock_keys.include? :email)
          unlock_user = user.class.send_unlock_instructions(:email => user.email)
          unlock_user.should eq(user)
        end
      end

      it "finds user using username key" do
        if (unlock_keys.include? :username)
          unlock_user = user.class.send_unlock_instructions(:username => user.username)
          unlock_user.should eq(user)
        end
      end

      it "finds user using login key" do
        if (unlock_keys.include? :login)
          unlock_user = user.class.send_unlock_instructions(:login => user.email)
          unlock_user.should eq(user)
          unlock_user = user.class.send_unlock_instructions(:login => user.username)
          unlock_user.should eq(user)
        end
      end
    end
    
    describe "locks after maximum attempts" do
      before(:each) do
        user.unlock_access!
      end

      it "allows authentication before failed attempt limit" do
        (maximum_attempts - 1).times { user.valid_for_authentication?{ false } }
        user.active_for_authentication?.should be_true
      end

      it "allows authentication before failed attempt limit" do
        (maximum_attempts).times { user.valid_for_authentication?{ false } }
        user.active_for_authentication?.should be_true
      end

      it "allows authentication before failed attempt limit" do
        (maximum_attempts + 1).times { user.valid_for_authentication?{ false } }
        user.active_for_authentication?.should be_false
      end
    end
    
    describe "unlock in time limit" do
      before(:each) do
        user.unlock_access!
      end

      it "prevents unlock within unlock time" do
        user.update_attribute(:locked_at, (unlock_in - 1.minute).ago.utc)
        user.access_locked?.should be_true
      end
    end
  end

  shared_examples_for "devise rememberable" do |factory|
    let(:user) do 
      user = FactoryGirl.build(factory)
      user.confirm!
      user.reload
    end
    before(:all) do
      # Rememberable Configuration
      remember_for ||= 2.weeks
    end
    
    describe "remember_me expiry" do
      context "remembered" do
        before(:all) { user.remember_me! }

        it "has remember not expired" do
          user.remember_expired?.should be_false
        end

        it "expires at 'remember_for' setting" do
          user.remember_expires_at.should be_within(1.minute).of(remember_for.from_now)
        end
      end
      context "forgotten" do
        before(:each) { user.forget_me! }

        it "has remember expired" do
          user.remember_expired?.should be_true
        end
      end
    end
  end

  shared_examples_for "devise timeoutable" do |factory|
    let(:user) do 
      user = FactoryGirl.build(factory)
      user.confirm!
      user.reload
    end
    before(:all) do
      # Timeoutable Configuration
      timeout_in ||= 30.minutes
    end
    
    describe "timeoutable" do
      it "times out after timeout limit" do
        user.timedout?((timeout_in + 1.minute).ago).should be_true
      end

      it "does not time out before timeout limit" do
        user.timedout?((timeout_in - 1.minute).ago).should be_false
      end
    end
  end

  shared_examples_for "devise confirmable" do |factory|
    let(:user) { FactoryGirl.build(factory) }
    before(:all) do
      # Confirmable Configuration
      reconfirmable ||= true
      confirmation_keys ||= [:email]
    end

    describe "sending confirmation email" do
      let(:confirmation_email) do
        user.send_confirmation_instructions
        confirmation_email = ActionMailer::Base.deliveries.last
      end

      it "sends email to user" do
        confirmation_email.to.should eq([user.email])
      end
      
      it "sends email from 'no-reply@credda.com'" do
        confirmation_email.from.should eq(["no-reply@credda.com"])
      end

      it "sends email with recovery subject line" do
        subject = YAML.load_file("#{Rails.root}/config/locales/devise.en.yml")['en']['devise']['mailer']['confirmation_instructions']['subject']
        confirmation_email.subject.should eq(subject)
      end
      
      it "sends email with the correct key" do
        confirmation_email.body.should match(/#{user.confirmation_token}/)
      end
    end

    describe "confirmable" do
      context "user not confirmed" do
        it "should not be confirmed" do
          user.confirmed?.should be_false          
        end
      end
      context "user confirmed" do
        before(:each) do
          user.confirm!          
        end

        it "should be confirmed" do
          user.confirmed?.should be_true
        end
      end      
    end
  end  
end