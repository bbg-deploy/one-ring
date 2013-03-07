class HelloSignService
  # Initializer
  #----------------------------------------------------------------------------
  def initialize(params = {})
    initialize_gateway
  end

  # Methods
  #----------------------------------------------------------------------------

  # Helper Functions
  #----------------------------------------------------------------------------
  private
  def auth
    return YAML.load_file("#{Rails.root}/config/hello_sign.yml")[Rails.env]
  end

  def initialize_gateway
    @gateway = HelloSign::Client.new(
      email_address: auth['email'], 
      password: auth['password']
    )

#    @gateway = ActiveMerchant::Billing::AuthorizeNetCimGateway.new(
#      :login    => auth['login'],
#      :password => auth['key'],
#      :test => false
#    )
  end
end