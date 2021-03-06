class Store::RegistrationsController < Devise::RegistrationsController
  include ActiveModel::ForbiddenAttributesProtection
  layout 'store_layout', :only => [:edit, :update, :destroy, :cancel_account]

  # Authentication filters
  prepend_before_filter :require_no_authentication, :only => [:new, :create, :cancel]
  prepend_before_filter :authenticate_scope!, :only => [:edit, :update, :destroy, :cancel_account]
  before_filter :check_scope_conflict

  # GET /store/sign_up
  def new
    @store = Store.new
    1.times { @store.addresses.build }
    1.times { @store.phone_numbers.build }
    respond_with @store
  end

  # POST /store
  def create
    @store = Store.new(create_store_params)

    @store.skip_confirmation_notification! unless @store.approved?
    if @store.save
      if @store.active_for_authentication?
        set_flash_message :notice, :signed_up
        sign_in @store
        respond_with @store, :location => store_home_path
      else
        StoreAuthenticationMailer.approval_notification(@store).deliver unless @store.approved?
        set_flash_message :notice, :"signed_up_but_#{@store.inactive_message}"
        expire_session_data_after_sign_in!
        respond_with @store, :location => home_path
      end
    else
      flash[:alert] = YAML.load_file("#{Rails.root}/config/locales/devise.en.yml")['en']['devise']['failure']['invalid_data']
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
      flash[:alert] = YAML.load_file("#{Rails.root}/config/locales/devise.en.yml")['en']['devise']['failure']['invalid_data']
      clean_up_passwords @store
      respond_with @store
    end
  end

  # DELETE /store
  def destroy
    @store = current_store
    if @store.destroy
      Devise.sign_out_all_scopes ? sign_out : sign_out(:store)
      set_flash_message :notice, :destroyed
    else
      set_flash_message :alert, :cannot_be_destroyed
    end
    respond_with @store, :location => home_path
  end

  # DELETE /store/cancel_account
  def cancel_account
    @store = current_store
    if @store.cancel_account
      Devise.sign_out_all_scopes ? sign_out : sign_out(:store)
      set_flash_message :notice, :cancelled
    else
      set_flash_message :alert, :cannot_be_cancelled
    end    
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
  def check_scope_conflict
    redirect_to store_scope_conflict_path if (!(current_user.nil?) && (current_store.nil?))
  end

  def after_sign_in_path_for(store)
    store_home_path
  end

  private
  def create_store_params
    params.require(:store).permit(
      :username, :password, :password_confirmation, :email, :email_confirmation, 
      :name, :employer_identification_number, 
      {:addresses_attributes  => [:street, :city, :state, :zip_code, :country]}, 
      {:phone_numbers_attributes => [:phone_number_type, :phone_number, :cell_phone]}, :terms_agreement )
  end

  def update_store_params
    params.require(:store).permit(
      :username, :password, :password_confirmation, :current_password, :email, :email_confirmation, 
      :name, :employer_identification_number, 
      {:addresses_attributes  => [:street, :city, :state, :zip_code, :country]}, 
      {:phone_numbers_attributes => [:phone_number_type, :phone_number, :cell_phone]} )
  end
end