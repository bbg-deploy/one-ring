class Customer::RegistrationsController < Devise::RegistrationsController
  include ActiveModel::ForbiddenAttributesProtection

  # These are filters from Devise
  prepend_before_filter :require_no_authentication, :only => [ :new, :create, :cancel ]
  prepend_before_filter :authenticate_scope!, :only => [:edit, :update, :destroy]
  
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
        set_flash_message :notice, :signed_up
        sign_in @customer
        respond_with @customer, :location => after_sign_up_path_for(@customer)
      else
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
#    @customer = Customer.find(params[:id])
#    respond_with @customer

    render :edit
  end
  
  def update    
    if params[:customer][:password].blank?
      params[:customer][:password] = params[:customer][:current_password]
      params[:customer][:password_confirmation] = params[:customer][:current_password]
    end
    
    if params[:customer][:password] == params[:customer][:current_password]
      params[:customer][:password_confirmation] = params[:customer][:password]
    end

    if params[:customer][:email] == params[:customer][:current_email]
      params[:customer][:email_confirmation] = params[:customer][:email]
    end

    super
  end

  protected
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
    params.require(:customer).permit(:username, :password, :password_confirmation, :email, :email_confirmation, :first_name, :middle_name, :last_name, :date_of_birth, :social_security_number, :mailing_address_attributes, :phone_number_attributes)
  end
end