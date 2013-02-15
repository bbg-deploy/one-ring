class Store::PasswordsController < Devise::PasswordsController
  include ActiveModel::ForbiddenAttributesProtection

  prepend_before_filter :require_no_authentication
  # Render the #edit only if coming from a reset password email link
  append_before_filter :assert_reset_token_passed, :only => :edit

  # GET /store/password/new
  def new
    @store = Store.new
  end

  # POST /store/password
  def create
    @store = Store.send_reset_password_instructions(create_store_params)

    if successfully_sent?(@store)
      respond_with({}, :location => new_store_session_path)
    else
      respond_with(@store)
    end
  end

  # GET /store/password/edit?reset_password_token=abcdef
  def edit
    @store = Store.find_or_initialize_with_error_by(:reset_password_token, params[:reset_password_token])
    if @store.errors.empty?
      respond_with(@store)
    else
      set_flash_message :alert, :invalid_reset_token
      redirect_to new_store_session_path
    end
  end

  # PUT /store/password
  def update
    @store = Store.reset_password_by_token(update_store_params)

    if @store.errors.empty?
      @store.unlock_access! if unlockable?(@store)
      flash_message = @store.active_for_authentication? ? :updated : :updated_not_active
      set_flash_message(:notice, flash_message)
      sign_in(:store, @store)
      respond_with @store, :location => store_home_path
    else
      respond_with @store
    end
  end

  protected
  def after_sign_in_path_for(store)
    store_home_path
  end

  # Check if a reset_password_token is provided in the request
  def assert_reset_token_passed
    if params[:reset_password_token].blank?
      set_flash_message(:error, :no_token)
      redirect_to new_store_session_path
    end
  end

  # Check if proper Lockable module methods are present & unlock strategy
  # allows to unlock customer on password reset
  def unlockable?(store)
    store.respond_to?(:unlock_access!) &&
      store.respond_to?(:unlock_strategy_enabled?) &&
      store.unlock_strategy_enabled?(:email)
  end

  private
  def create_store_params
    params.require(:store).permit(:email)
  end

  def update_store_params
    params.require(:store).permit(:reset_password_token, :password, :password_confirmation)
  end
end