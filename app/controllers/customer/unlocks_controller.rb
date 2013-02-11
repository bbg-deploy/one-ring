class Customer::UnlocksController < Devise::UnlocksController
  include ActiveModel::ForbiddenAttributesProtection

  prepend_before_filter :require_no_authentication

  # GET /customer/unlock/new
  def new
    @customer = Customer.new
  end

  # POST /customer/unlock
  def create
    @customer = Customer.send_unlock_instructions(create_customer_params)

    if successfully_sent?(@customer)
      respond_with({}, :location => new_customer_session_path)
    else
      respond_with(@customer)
    end
  end

  # GET /customer/unlock?unlock_token=abcdef
  def show
    @customer = Customer.unlock_access_by_token(params[:unlock_token])

    if @customer.errors.empty?
      set_flash_message :notice, :unlocked
      respond_with_navigational(@customer){ redirect_to new_customer_session_path }
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