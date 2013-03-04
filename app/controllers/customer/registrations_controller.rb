class Customer::RegistrationsController < Devise::RegistrationsController
  include ActiveModel::ForbiddenAttributesProtection

  # Authentication filters
  prepend_before_filter :require_no_authentication, :only => [ :new, :create, :cancel ]
  prepend_before_filter :authenticate_scope!, :only => [:edit, :update, :destroy]
  before_filter :check_scope_conflict

  # GET /customer/sign_up
  def new
    @customer = Customer.new
    @customer.build_mailing_address
    @customer.build_phone_number
    @customer.build_alerts_list
    respond_with @customer
  end

  # POST /customer
  def create
    @customer = Customer.new(create_customer_params)

    if @customer.save
      if @customer.active_for_authentication?
        # set_flash_message is a Devise method
        set_flash_message :notice, :signed_up
        sign_in @customer
        respond_with @customer, :location => customer_home_path
      else
        # set_flash_message is a Devise method
        set_flash_message :notice, :"signed_up_but_#{@customer.inactive_message}"
        expire_session_data_after_sign_in!
        respond_with @customer, :location => home_path
      end
    elsif @customer.errors.empty?
      # This catches Authorize.net errors
      flash[:error] = "We had a problem processing your data. Our team has been notified of this error. Please try again later."
      redirect_to :action => :new
    else
      flash[:error] = "There was a problem with some of your information"
      clean_up_passwords @customer
      respond_with @customer
    end
  end

  # GET /customer/edit
  def edit
    @customer = current_customer
    respond_with @customer
  end
  
  # PUT /customer
  def update
    @customer = current_customer
    prev_unconfirmed_email = @customer.unconfirmed_email if @customer.respond_to?(:unconfirmed_email)

    if @customer.update_with_password(update_customer_params)
      flash_key = update_needs_confirmation?(@customer, prev_unconfirmed_email) ? :update_needs_confirmation : :updated
      set_flash_message :notice, flash_key
      sign_in :customer, @customer, :bypass => true
      respond_with @customer, :location => customer_home_path
    elsif @customer.errors.empty?
      # This catches Authorize.net errors
      flash[:error] = "We had a problem processing your data. Our team has been notified of this error. Please try again later."
      redirect_to :action => :edit
    else
      # Set passwords to blank before we redirect
      clean_up_passwords @customer
      respond_with @customer
    end
  end

  # DELETE /customer
  def destroy
    # Don't actually destroy the customer object, just set it to 'cancelled'
    @customer = current_customer
    @customer.cancel_account!
    Devise.sign_out_all_scopes ? sign_out : sign_out(:customer)
    set_flash_message :notice, :destroyed
    respond_with @customer, :location => home_path
  end

  # GET /customer/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  def cancel
    expire_session_data_after_sign_in!
    redirect_to new_customer_registration_path
  end

  protected
  def check_scope_conflict
    redirect_to customer_scope_conflict_path if (!(current_user.nil?) && (current_customer.nil?))
  end

  def after_sign_in_path_for(customer)
    customer_home_path
  end

  private
  def create_customer_params
    params.require(:customer).permit(
      :username, :password, :password_confirmation, :email, :email_confirmation, 
      :first_name, :middle_name, :last_name, :date_of_birth, :social_security_number, 
      {:mailing_address_attributes  => [:street, :city, :state, :zip_code, :country]}, 
      {:phone_number_attributes => [:phone_number_type, :phone_number, :cell_phone]}, 
      {:alerts_list_attributes => [:mail, :email, :sms, :phone]}, 
      :terms_agreement )
  end

  def update_customer_params
    params.require(:customer).permit(
      :username, :password, :password_confirmation, :current_password, :email, :email_confirmation, 
      :first_name, :middle_name, :last_name, :date_of_birth, :social_security_number, 
      {:mailing_address_attributes  => [:street, :city, :state, :zip_code, :country]}, 
      {:phone_number_attributes => [:phone_number_type, :phone_number, :cell_phone]}, 
      {:alerts_list_attributes => [:mail, :email, :sms, :phone]} )
  end
end