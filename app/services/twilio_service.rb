class TwilioService
=begin
  # Initializer
  #----------------------------------------------------------------------------
  def initialize(params = {})
    @client = Twilio::REST::Client.new(auth['account_sid'], auth['auth_token'])
    @account = @client.account
  end

  # Signature Page Methods
  #----------------------------------------------------------------------------
  def send_text_message(to_phone, from_phone, message) 
    @twilio_client.account.sms.messages.create(
      :to => to_phone,
      :from => from_phone,
      :body => "Test message for Credda."
    )
  end

  private
  def auth
    return YAML.load_file("#{Rails.root}/config/twilio.yml")[Rails.env]
  end
=end
end