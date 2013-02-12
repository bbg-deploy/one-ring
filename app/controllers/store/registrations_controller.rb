class Store::RegistrationsController < Devise::RegistrationsController
  include ActiveModel::ForbiddenAttributesProtection

  # Authentication filters
  prepend_before_filter :require_no_authentication, :only => [ :new, :create, :cancel ]
  prepend_before_filter :authenticate_scope!, :only => [:edit, :update, :destroy]

  # GET /store/sign_up
  def new
    @store = Store.new
    @store.build_mailing_address
    @store.build_phone_number
    respond_with @store
  end

  # POST /store
  def create
    @store = Store.new(create_store_params)

    if @store.save
      if @store.active_for_authentication?
        set_flash_message :notice, :signed_up
        sign_in @store
        respond_with @store, :location => store_home_path
      else
        set_flash_message :notice, :"signed_up_but_#{@store.inactive_message}"
        expire_session_data_after_sign_in!
        respond_with @store, :location => home_path
      end
    else
      flash[:error] = "There was a problem with some of your information"
      clean_up_passwords @store
      respond_with @store
    end
  end

  # GET /store/edit
  def edit
    @store = current_store
    respond_with @store
  end
  
  # PUT /store
  def update
    @store = current_store
    prev_unconfirmed_email = @store.unconfirmed_email if @store.respond_to?(:unconfirmed_email)

    if @store.update_with_password(update_store_params)
      flash_key = update_needs_confirmation?(@store, prev_unconfirmed_email) ? :update_needs_confirmation : :updated
      set_flash_message :notice, flash_key
      sign_in :store, @store, :bypass => true
      respond_with @store, :location => store_home_path
    else
      # Set passwords to blank before we redirect
      clean_up_passwords @customer
      respond_with @customer
    end
  end

  # DELETE /store
  def destroy
    # Don't actually destroy the store object, just set it to 'cancelled'
    @store = current_store
    @store.cancel_account
    Devise.sign_out_all_scopes ? sign_out : sign_out(:store)
    set_flash_message :notice, :destroyed
    respond_with @store, :location => home_path
  end

  # GET /store/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  def cancel
    expire_session_data_after_sign_in!
    redirect_to new_store_registration_path
  end

  protected
  def after_sign_in_path_for(store)
    store_home_path
  end

  private
  def create_store_params
    params.require(:store).permit(:username, :password, :password_confirmation, :email, :email_confirmation, :first_name, :middle_name, :last_name, :date_of_birth, :social_security_number, :mailing_address_attributes, :phone_number_attributes, :terms_agreement)
  end

  def update_store_params
    params.require(:store).permit(:username, :password, :password_confirmation, :current_password, :email, :email_confirmation, :first_name, :middle_name, :last_name, :date_of_birth, :social_security_number, :mailing_address_attributes, :phone_number_attributes)
  end
end