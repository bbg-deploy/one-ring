class AuthorizeNetService
  # Initializer
  #----------------------------------------------------------------------------
  def initialize(params = {})
    set_server_mode
    initialize_gateway
  end

  # Customer Profile Methods
  #----------------------------------------------------------------------------
  def create_cim_customer_profile(customer = nil)
    if !customer.is_a?(Customer)
      raise StandardError, "create_cim_customer_profile requires valid Customer"
    elsif customer.username.nil?
      raise StandardError, "create_cim_customer_profile requires Customer with username"
    elsif customer.email.nil?
      raise StandardError, "create_cim_customer_profile requires Customer with email"
    end

    customer_profile_information = {
      :profile => {
        :merchant_customer_id => customer.username.first(20),
        :email => customer.email
      }
    }
    
    response = @gateway.create_customer_profile(customer_profile_information)
    
    if response.success?
      customer.cim_customer_profile_id = response.params["customer_profile_id"]
      return true
    else
      handle_response_errors(response)
    end
  end

  def get_cim_customer_profile(customer = nil)
    if !customer.is_a?(Customer)
      raise StandardError, "get_cim_customer_profile requires valid Customer"
    elsif customer.cim_customer_profile_id.nil?
      raise StandardError, "get_cim_customer_profile requires Customer with cim_customer_profile_id"
    end

    customer_profile_id = {
      :customer_profile_id => customer.cim_customer_profile_id
    }
    
    response = @gateway.get_customer_profile(customer_profile_id)

    if response.success?
      return response.params["profile"]
    else
      handle_response_errors(response)
    end
  end

  def update_cim_customer_profile(customer = nil)
    if !customer.is_a?(Customer)
      raise StandardError, "update_cim_customer_profile requires valid Customer"
    elsif customer.cim_customer_profile_id.nil?
      raise StandardError, "update_cim_customer_profile requires Customer with cim_customer_profile_id"
    end

    current_profile_information = {
      :profile => self.get_cim_customer_profile(customer)
    }

    new_profile_information = {
      :profile => {
        :customer_profile_id => customer.cim_customer_profile_id,
        :merchant_customer_id => customer.username.first(20),
        :email => customer.email
      }
    }
    
    customer_profile_information = current_profile_information.merge(new_profile_information)
    response = @gateway.update_customer_profile(customer_profile_information)
    
    if response.success?
      return true
    else
      handle_response_errors(response)
    end
  end

  def delete_cim_customer_profile(customer = nil)
    if !customer.is_a?(Customer)
      raise StandardError, "delete_cim_customer_profile requires valid Customer"
    elsif customer.cim_customer_profile_id.nil?
      raise StandardError, "delete_cim_customer_profile requires Customer with cim_customer_profile_id"
    end
    
    customer_profile_information = {
      :customer_profile_id => customer.cim_customer_profile_id
    }

    response = @gateway.delete_customer_profile(customer_profile_information)
    
    if response.success?
      return true
    else
      handle_response_errors(response)
    end
  end

  # Customer Payment Profile Methods
  #----------------------------------------------------------------------------
  def create_cim_customer_payment_profile(payment_profile = nil)
    if !payment_profile.is_a?(PaymentProfile)
      raise StandardError, "create_cim_customer_payment_profile requires valid PaymentProfile"
    elsif payment_profile.customer.cim_customer_profile_id.nil?
      raise StandardError, "create_cim_customer_payment_profile requires Customer with cim_customer_profile_id"
    end

    customer_payment_profile_information = {
      :customer_profile_id => payment_profile.customer.cim_customer_profile_id,
      :payment_profile => {
        :customer_type => "individual",
        :bill_to => payment_profile.authorize_net_billing_details,
        :payment => payment_profile.authorize_net_payment_details
      }
    }
    
    response = @gateway.create_customer_payment_profile(customer_payment_profile_information)
    
    if response.success?
      return response.params["customer_payment_profile_id"]
    else
      handle_response_errors(response)
    end
  end

  def get_cim_customer_payment_profile(payment_profile = nil)
    if !payment_profile.is_a?(PaymentProfile)
      raise StandardError, "get_cim_customer_payment_profile requires valid PaymentProfile"
    elsif payment_profile.cim_customer_payment_profile_id.nil?
      raise StandardError, "get_cim_customer_payment_profile requires cim_customer_payment_profile_id"
    elsif payment_profile.customer.cim_customer_profile_id.nil?
      raise StandardError, "get_cim_customer_payment_profile requires Customer with cim_customer_profile_id"
    end

    customer_payment_profile_information = {
      :customer_profile_id => payment_profile.customer.cim_customer_profile_id,
      :customer_payment_profile_id => payment_profile.cim_customer_payment_profile_id
    }
    
    response = @gateway.get_customer_payment_profile(customer_payment_profile_information)
    
    if response.success?
      return response.params["payment_profile"]
    else
      handle_response_errors(response)
    end
  end

  def update_cim_customer_payment_profile(payment_profile = nil)
    if !payment_profile.is_a?(PaymentProfile)
      raise StandardError, "update_cim_customer_payment_profile requires valid PaymentProfile"
    elsif payment_profile.cim_customer_payment_profile_id.nil?
      raise StandardError, "update_cim_customer_payment_profile requires cim_customer_payment_profile_id"
    elsif payment_profile.customer.cim_customer_profile_id.nil?
      raise StandardError, "update_cim_customer_payment_profile requires Customer with cim_customer_profile_id"
    end

    current_payment_profile_information = {
      :payment_profile => self.get_cim_customer_payment_profile(payment_profile)
    }

    new_payment_profile_information = {
      :customer_profile_id => payment_profile.customer.cim_customer_profile_id,
      :payment_profile => {
        :customer_payment_profile_id => payment_profile.cim_customer_payment_profile_id,
        :customer_type => "individual",
        :bill_to => payment_profile.authorize_net_billing_details,
        :payment => payment_profile.authorize_net_payment_details
      }
    }

    customer_payment_profile_information = current_payment_profile_information.merge(new_payment_profile_information)
    response = @gateway.update_customer_payment_profile(customer_payment_profile_information)
    
    if response.success?
      return true
    else
      handle_response_errors(response)
    end
  end

  def delete_cim_customer_payment_profile(payment_profile = nil)
    if !payment_profile.is_a?(PaymentProfile)
      raise StandardError, "delete_cim_customer_payment_profile requires valid PaymentProfile"
    elsif payment_profile.cim_customer_payment_profile_id.nil?
      raise StandardError, "delete_cim_customer_payment_profile requires cim_customer_payment_profile_id"
    elsif payment_profile.customer.cim_customer_profile_id.nil?
      raise StandardError, "delete_cim_customer_payment_profile requires Customer with cim_customer_profile_id"
    end

    customer_payment_profile_information = {
      :customer_profile_id => payment_profile.customer.cim_customer_profile_id,
      :customer_payment_profile_id => payment_profile.cim_customer_payment_profile_id
    }

    response = @gateway.delete_customer_payment_profile(customer_payment_profile_information)
    
    if response.success?
      return true
    else
      handle_response_errors(response)
    end
  end

  # Customer Transaction Methods
  #----------------------------------------------------------------------------
  def create_cim_customer_profile_transaction(payment_profile = nil, amount = BigDecimal.new("0.0"))
    if !payment_profile.is_a?(PaymentProfile)
      raise StandardError, "create_cim_customer_profile_transaction requires valid PaymentProfile"
    elsif payment_profile.cim_customer_payment_profile_id.nil?
      raise StandardError, "create_cim_customer_profile_transaction requires cim_customer_payment_profile_id"
    elsif payment_profile.customer.cim_customer_profile_id.nil?
      raise StandardError, "create_cim_customer_profile_transaction requires Customer with cim_customer_profile_id"
    elsif amount <= BigDecimal.new("0.0")
      raise StandardError, "create_cim_customer_profile_transaction requires amount > 0"
    end

    transaction_information = {
      :transaction => {
        :type                        => :auth_capture,
        :amount                      => amount,
        :customer_profile_id         => payment_profile.customer.cim_customer_profile_id,
        :customer_payment_profile_id => payment_profile.cim_customer_payment_profile_id
      }
    }
    
    response = @gateway.create_customer_profile_transaction(transaction_information)    
    
    if response.success?
      return true
    else
      handle_response_errors(response)
    end 
  end

  # Helper Functions
  #----------------------------------------------------------------------------
  private
  def auth
    return YAML.load_file("#{Rails.root}/config/authorize_net.yml")[Rails.env]
  end

  def set_server_mode
    ActiveMerchant::Billing::Base.mode = auth['mode'].to_sym
  end
  
  def initialize_gateway
    @gateway = ActiveMerchant::Billing::AuthorizeNetCimGateway.new(
      :login    => auth['login'],
      :password => auth['key'],
      :test => false
    )
  end
  
  def handle_response_errors(response)
    response_code = response.params['messages']['message']['code']
    error_codes = YAML.load_file("#{Rails.root}/config/authorize_net.yml")['error_codes']
    
    if error_codes['processing'].include?(response_code)
      raise StandardError, response.message
    elsif error_codes['request'].include?(response_code)
      raise StandardError, response.message
    elsif error_codes['data'].include?(response_code)
      raise StandardError, response.message
    elsif error_codes['transaction'].include?(response_code)
      raise StandardError, response.message
    else
      raise StandardError, response.message
    end
  end
end