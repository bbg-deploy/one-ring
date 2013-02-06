class Customer::RegistrationsController < Devise::RegistrationsController
  # This prevents users from canceling their accounts without the
  # proper permissions
  #--------------------------------------------------------------
  before_filter :check_permissions, :only => [:destroy]

  # GET /customer/sign_up
  def new
    @customer = Customer.new
    @customer.build_mailing_address
    @customer.build_phone_number
#    1.times { @customer.phone_numbers.build }
    respond_with @product
  end

  # POST /customer
  def create
    @customer = Customer.new(params[:customer])
        flash[:notice] = "Testing"

    if @customer.save
      if @customer.active_for_authentication?
        flash[:notice] = "Testing"
#        set_flash_message(:notice, :signed_up)
        sign_in @customer
        respond_with @customer, :location => after_sign_up_path_for(@customer)
      else
        flash[:notice] = "Testing"
#        set_flash_message :notice, :"signed_up_but_#{@customer.inactive_message}"
        expire_session_data_after_sign_in!
        respond_with @customer, :location => after_inactive_sign_up_path_for(@customer)
      end
    else
      #TODO: What does clean_up_passwords do?
      clean_up_passwords @customer
      respond_with @customer
    end
  end

#  def create
#    @product = Product.create
#    redirect_to wizard_path(steps.first, :product_id => @product.id)
#  end

  def update
    
    #TODO: Break this into a separate form for password/username updates and
    #      one for updating contact information
    # If the user hasn't opted to change his password, keep it the same
    #----------------------------------------------------------------------------------
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

  def check_permissions
    # Get CanCan authorization before an account can be destroyed
    #------------------------------------------------------------
    authorize! :destroy, resource
  end
end