module WebmockMacros
  @google_maps_api_regex = "http:\/\/maps.googleapis.com\/maps\/api\/geocode\/json.*"
  @authorize_net_api_regex = "https:\/\/apitest.authorize.net\/xml\/v1\/request.api.*"
  @twilio_api_regex = "https://api.twilio.com/.*/SMS/Messages.*"

  #Note:  To get example responses, use Hurl.it
  
  def webmock_geocoder
    response = File.new "spec/support/webmock/geocoder/geocoder_success.json"
    stub_request(:get, /#{@google_maps_api_regex}/).to_return(response)
  end

  def webmock_authorize_net(method, response_code)
    if (response_code == :I00001)
      response = File.new "spec/support/webmock/authorize.net/#{method}/#{response_code}.xml"
    else
      response = File.new "spec/support/webmock/authorize.net/errors/#{response_code}.xml"
    end
    
    stub_request(:post, /#{@authorize_net_api_regex}/).with(:body => /#{method}/).to_return(response)
  end

  def webmock_authorize_net_all_successful
    # Customer Profile Methods
    webmock_authorize_net("createCustomerProfileRequest", :I00001)
    webmock_authorize_net("getCustomerProfileRequest", :I00001)
    webmock_authorize_net("updateCustomerProfileRequest", :I00001)
    webmock_authorize_net("deleteCustomerProfileRequest", :I00001)
    # Customer Payment Profile Methods
    webmock_authorize_net("createCustomerPaymentProfileRequest", :I00001)
    webmock_authorize_net("getCustomerPaymentProfileRequest", :I00001)
    webmock_authorize_net("updateCustomerPaymentProfileRequest", :I00001)
    webmock_authorize_net("deleteCustomerPaymentProfileRequest", :I00001)
    # Customer Profile Transaction Methods
    webmock_authorize_net("createCustomerProfileTransactionRequest", :I00001)
  end

  def webmock_twilio(method, response_code)
    if (response_code == :success)
      response = File.new "spec/support/webmock/twilio/#{method}/#{response_code}.json"
    else
      response = File.new "spec/support/webmock/twilio/#{method}/errors/#{response_code}.json"
    end
    stub_request(:post, /#{@twilio_api_regex}/).to_return(response)   
  end
  
  def webmock_twilio_successful
    webmock_twilio(:sms, :success)
  end
end