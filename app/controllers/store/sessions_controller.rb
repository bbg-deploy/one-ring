class Store::SessionsController < Devise::SessionsController
  prepend_before_filter :require_no_authentication, :only => [ :new, :create ]
  prepend_before_filter :allow_params_authentication!, :only => :create
  prepend_before_filter { request.env["devise.skip_timeout"] = true }
  before_filter :check_scope_conflict, :only => [:new, :create]

  # GET /store/sign_in
  def new
    @store = Store.new
    clean_up_passwords(@store)
    respond_with(@store, serialize_options(@store))
  end

  # POST /store/sign_in
  def create
    @store = warden.authenticate!(auth_options)
    set_flash_message(:notice, :signed_in)
    sign_in(:store, @store)
    respond_with @store, :location => after_sign_in_path_for(@store)
  end

  # DELETE /store/sign_out
  def destroy
    redirect_path = home_path
    signed_out = (Devise.sign_out_all_scopes ? sign_out : sign_out(:store))
    set_flash_message :notice, :signed_out if signed_out

    # We actually need to hardcode this as Rails default responder doesn't
    # support returning empty response on GET request
    respond_to do |format|
      format.all { head :no_content }
      format.any(*navigational_formats) { redirect_to redirect_path }
    end
  end

  protected
  def check_scope_conflict
    redirect_to store_scope_conflict_path if (!(current_user.nil?) && (current_store.nil?))
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
    if session[:post_auth_path]
      url = session[:post_auth_path]
      session[:post_auth_path] = nil
    else
      url = store_home_path
    end
    url
  end
end