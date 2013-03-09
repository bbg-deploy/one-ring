class Customer::SessionsController < Devise::SessionsController
  prepend_before_filter :check_scope_conflict, :only => [:new, :create, :destroy]
  prepend_before_filter :require_no_authentication, :only => [:new, :create]
  prepend_before_filter :allow_params_authentication!, :only => :create
  prepend_before_filter { request.env["devise.skip_timeout"] = true }

  # GET /customer/sign_in
  def new
    @customer = Customer.new
    clean_up_passwords(@customer)
    respond_with(@customer, serialize_options(@customer))
  end

  # POST /customer/sign_in
  def create
    @customer = warden.authenticate!(auth_options)
    
    set_flash_message(:notice, :signed_in)
    sign_in(:customer, @customer)
    respond_with @customer, :location => after_sign_in_path_for(@customer)
  end

  # DELETE /customer/sign_out
  def destroy
    redirect_path = home_path
    signed_out = (Devise.sign_out_all_scopes ? sign_out : sign_out(:customer))
    set_flash_message :notice, :signed_out if signed_out

    # We actually need to hardcode this as Rails default responder doesn't
    # support returning empty response on GET request
    respond_to do |format|
      format.all { head :no_content }
      format.any(*navigational_formats) { redirect_to redirect_path }
    end
  end

  # GET /customer/scope_conflict
  def scope_conflict
    redirect_to :action => :new if current_user.nil?
    redirect_to customer_home_path unless current_customer.nil?
    session[:pre_conflict_path] = request.referer if (!current_user.nil?) && (current_customer.nil?)
  end

  # DELETE /customer/resolve_conflict
  def resolve_conflict
    # Signs out all scopes
    sign_out
    redirect_to :action => :new
  end

  protected
  def check_scope_conflict
    redirect_to customer_scope_conflict_path if (!(current_user.nil?) && (current_customer.nil?))
    redirect_to customer_scope_conflict_path if (!(current_store.nil?) && (action_name == "create"))
    redirect_to customer_scope_conflict_path if (!(current_employee.nil?) && (action_name == "create"))
  end

  def serialize_options(resource)
    methods = resource_class.authentication_keys.dup
    methods = methods.keys if methods.is_a?(Hash)
    methods << :password if resource.respond_to?(:password)
    { :methods => methods, :only => [:password] }
  end

  def auth_options
    { :scope => resource_name, :recall => "#{controller_path}#new" }
  end
  
  protected
  # Direct the user back to original request after sign in
  #-------------------------------------------------------
  # http://stackoverflow.com/questions/4291755/rspec-test-of-custom-devise-session-controller-fails-with-abstractcontrollerac
  def after_sign_in_path_for(resource)
    if session[:pre_conflict_path]
      url = session[:pre_conflict_path]
      session[:pre_conflict_path] = nil
      session[:post_auth_path] = nil
    elsif session[:post_auth_path]
      url = session[:post_auth_path]
      session[:post_auth_path] = nil
    else
      url = customer_home_path
    end
    url
  end
end