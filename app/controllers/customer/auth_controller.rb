class Customer::AuthController < Customer::ApplicationController
  before_filter :authenticate_customer!, :except => [:access_token]
  skip_before_filter :verify_authenticity_token, :only => [:access_token]

  #TODO: re-evaluate this; maybe this is how I controll access for each client?
  skip_authorization_check

  # GET /authorize
  def authorize
    AccessGrant.prune!
    access_grant = current_customer.access_grants.create({:client => application, :state => params[:state]}, :without_protection => true)
    redirect_to access_grant.redirect_uri_for(params[:client_id])
  end

  # GET /access_token
  def access_token
    application = Client.authenticate(params[:client_id], params[:client_secret])

    if application.nil?
      render :json => {:error => "Could not find application"}
      return
    end

    access_grant = AccessGrant.authenticate(params[:code], application.id)
    if access_grant.nil?
      render :json => {:error => "Could not authenticate access code"}
      return
    end

    access_grant.start_expiry_period!
    render :json => {:access_token => access_grant.access_token, :refresh_token => access_grant.refresh_token, :expires_in => Devise.timeout_in.to_i}
  end

  def failure
    render :text => "ERROR: #{params[:message]}"
  end

  def customer
    hash = {
      :provider => 'credda',
      :id => current_customer.id.to_s,
      :info => {
         :email      => current_customer.email,
      },
      :extra => {
         :first_name => current_customer.first_name,
         :last_name  => current_customer.last_name
      }
    }

    render :json => hash.to_json
  end

  # Incase, we need to check timeout of the session from a different application!
  # This will be called ONLY if the user is authenticated and token is valid
  # Extend the UserManager session
  def isalive
    warden.set_user(current_customer, :scope => :customer)
    response = { 'status' => 'ok' }

    respond_to do |format|
      format.any { render :json => response.to_json }
    end
  end

  protected
  def application
    @application ||= Client.find_by_app_id(params[:client_id])
  end
end