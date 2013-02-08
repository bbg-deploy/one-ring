class Customer::RegistrationsController < Devise::RegistrationsController
  include ActiveModel::ForbiddenAttributesProtection

  # These are filters from Devise
  prepend_before_filter :require_no_authentication, :only => [ :new, :create, :cancel ]
  prepend_before_filter :authenticate_scope!, :only => [:edit, :update, :destroy]

  # I need to call this again, since this controller inherets from Devise and not my ApplicationController
  # TODO: Phase this out - find a better way!!
#  before_filter :get_customer

  # GET /customer/sign_up
  def new
    @customer = Customer.new
    @customer.build_mailing_address
    @customer.build_phone_number
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
        respond_with @customer, :location => after_sign_up_path_for(@customer)
      else
        # set_flash_message is a Devise method
        set_flash_message :notice, :"signed_up_but_#{@customer.inactive_message}"
        expire_session_data_after_sign_in!
        respond_with @customer, :location => after_inactive_sign_up_path_for(@customer)
      end
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
#    render :edit
  end
  
  def update
    @customer = current_customer
    prev_unconfirmed_email = @customer.unconfirmed_email if @customer.respond_to?(:unconfirmed_email)

    if @customer.update_with_password(update_customer_params)
      if is_navigational_format?
        flash_key = update_needs_confirmation?(@customer, prev_unconfirmed_email) ?
          :update_needs_confirmation : :updated
        set_flash_message :notice, flash_key
      end
      sign_in resource_name, @customer, :bypass => true
      respond_with @customer, :location => after_update_path_for(@customer)
    else
      # Set passwords to blank before we redirect
      clean_up_passwords @customer
      respond_with @customer
    end

=begin
    self.resource = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)
    prev_unconfirmed_email = resource.unconfirmed_email if resource.respond_to?(:unconfirmed_email)

    if resource.update_with_password(resource_params)
      if is_navigational_format?
        flash_key = update_needs_confirmation?(resource, prev_unconfirmed_email) ?
          :update_needs_confirmation : :updated
        set_flash_message :notice, flash_key
      end
      sign_in resource_name, resource, :bypass => true
      respond_with resource, :location => after_update_path_for(resource)
    else
      clean_up_passwords resource
      respond_with resource
    end
=end
  end

  protected
  def get_customer
    @current_customer = current_customer
  end

  def after_sign_up_path_for(resource)
    customer_home_path
  end
  
  def after_sign_in_path_for(resource)
    customer_home_path
  end

  def after_sign_out_path_for(resource)
    home_path
  end

  private
  def create_customer_params
    params.require(:customer).permit(:username, :password, :password_confirmation, :email, :email_confirmation, :first_name, :middle_name, :last_name, :date_of_birth, :social_security_number, :mailing_address_attributes, :phone_number_attributes, :terms_agreement)
  end

  def update_customer_params
    params.require(:customer).permit(:username, :password, :password_confirmation, :current_password, :email, :email_confirmation, :first_name, :middle_name, :last_name, :date_of_birth, :social_security_number, :mailing_address_attributes, :phone_number_attributes)
  end
end