class TwilioService
  # Initializer
  #----------------------------------------------------------------------------
  def initialize(params = {})
#    set_server_mode
#    initialize_gateway
  end

  # Signature Page Methods
  #----------------------------------------------------------------------------
  def send_sms
  end

  # Reusable Form Methods
  #----------------------------------------------------------------------------
  # Helper Functions
  #----------------------------------------------------------------------------
  private
  def auth
    return YAML.load_file("#{Rails.root}/config/twilio.yml")[Rails.env]
  end

  def login_password
    return "#{auth['login']}:#{auth['password']}"
  end
end