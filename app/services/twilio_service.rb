class TwilioService

  def initialize(params = {})
    initialize_gateway
  end


  def initialize(params = {})
    account_sid = 'ACb35a0f5a40a7ff080b63e594aef69935'
    auth_token = '45fae36b1d8de48f40dba573622a9d04'
  
    # set up a client to talk to the Twilio REST API
    @client = Twilio::REST::Client.new account_sid, auth_token
  end
  
  def get_account
    return @client.account
  end
  
  def send_test_sms
    # send an sms
    @client.account.sms.messages.create(
      :from => '+15109627923',
      :to => '+15109627923',
      :body => 'Test SMS!'
    )
  end


  private
  def auth
    return YAML.load_file("#{Rails.root}/config/twilio.yml")[Rails.env]
  end
  
  def initialize_gateway
    @gateway = Twilio::REST::Client.new auth['account_sid'], auth['auth_token']
  end
end