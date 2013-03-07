class TwilioService

  def initialize(params = {})
    initialize_gateway
  end
  
  def get_account
    return @gateway.account
  end
  
  def send_test_sms(to_number = nil, from_number = nil, body = nil)
    message = @gateway.account.sms.messages.create(
      :to => "+14108675309",
      :from => "+15005550006",
      :body => "All in the game, yo"
    )
    return message
  end


  private
  def auth
    return YAML.load_file("#{Rails.root}/config/twilio.yml")[Rails.env]
  end
  
  def initialize_gateway
    @gateway = Twilio::REST::Client.new auth['account_sid'], auth['auth_token']
  end
end