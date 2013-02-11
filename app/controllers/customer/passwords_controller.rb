class Customer::PasswordsController < Devise::PasswordsController
  include ActiveModel::ForbiddenAttributesProtection

  prepend_before_filter :require_no_authentication
  # Render the #edit only if coming from a reset password email link
  append_before_filter :assert_reset_token_passed, :only => :edit

  # GET /customer/password/new
  def new
    @customer = Customer.new
  end

  # POST /customer/password
  def create
    @customer = Customer.send_reset_password_instructions(create_customer_params)

    if successfully_sent?(@customer)
      respond_with({}, :location => new_customer_session_path)
    else
      respond_with(@customer)
    end
  end

  # GET /customer/password/edit?reset_password_token=abcdef
  def edit
    @customer = Customer.find_or_initialize_with_error_by(:reset_password_token, params[:reset_password_token])
    if @customer.errors.empty?
      respond_with(@customer)
    else
      set_flash_message :alert, :invalid_reset_token
      redirect_to new_customer_session_path
    end
  end

  # PUT /customer/password
  def update
    @customer = Customer.reset_password_by_token(update_customer_params)

    if @customer.errors.empty?
      @customer.unlock_access! if unlockable?(@customer)
      flash_message = @customer.active_for_authentication? ? :updated : :updated_not_active
      set_flash_message(:notice, flash_message)
      sign_in(:customer, @customer)
      respond_with @customer, :location => customer_home_path
    else
      respond_with @customer
    end
  end

  protected
  def after_sign_in_path_for(customer)
    customer_home_path
  end

  # Check if a reset_password_token is provided in the request
  def assert_reset_token_passed
    if params[:reset_password_token].blank?
      set_flash_message(:error, :no_token)
      redirect_to new_customer_session_path
    end
  end

  # Check if proper Lockable module methods are present & unlock strategy
  # allows to unlock customer on password reset
  def unlockable?(customer)
    customer.respond_to?(:unlock_access!) &&
      customer.respond_to?(:unlock_strategy_enabled?) &&
      customer.unlock_strategy_enabled?(:email)
  end

  private
  def create_customer_params
    params.require(:customer).permit(:email)
  end

  def update_customer_params
    params.require(:customer).permit(:reset_password_token, :password, :password_confirmation)
  end
end