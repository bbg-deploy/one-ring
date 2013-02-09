class Customer::ConfirmationsController < Devise::ConfirmationsController
  include ActiveModel::ForbiddenAttributesProtection

  # Authentication filters
  prepend_before_filter :require_no_authentication, :only => [ :new, :create, :show ]

  # GET /resource/confirmation/new
  def new
    @customer = Customer.new
  end

  # POST /resource/confirmation
  def create
    @customer = Customer.send_confirmation_instructions(create_customer_params)

    if successfully_sent?(@customer)
      respond_with({}, :location => home_path)
    else
      respond_with(@customer)
    end
  end

  # GET /resource/confirmation?confirmation_token=abcdef
  def show
    @customer = Customer.confirm_by_token(params[:confirmation_token])

    if @customer.errors.empty?
      set_flash_message(:notice, :confirmed) if is_navigational_format?
      sign_in(:customer, @customer)
      redirect_to customer_home_path
    else
      respond_with_navigational(@customer.errors, :status => :unprocessable_entity){ render :new }
    end
  end

  protected
  def after_sign_in_path_for(customer)
    customer_home_path
  end

  private
  def create_customer_params
    params.require(:customer).permit(:email)
  end
end