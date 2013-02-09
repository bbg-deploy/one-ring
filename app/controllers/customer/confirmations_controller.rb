class Customer::ConfirmationsController < Devise::ConfirmationsController
  # TODO: Write tests and refactor all of this!
  # GET /resource/confirmation/new
  def new
    @customer = Customer.new
  end

  # POST /resource/confirmation
  def create
=begin
    response = Customer.send_confirmation_instructions(params[:customer])

    if successfully_sent?(response)
      respond_with({}, :location => after_resending_confirmation_instructions_path_for(resource_name))
    else
      respond_with(response)
    end
=end
    self.resource = resource_class.send_confirmation_instructions(resource_params)

    if successfully_sent?(resource)
      respond_with({}, :location => after_resending_confirmation_instructions_path_for(resource_name))
    else
      respond_with(resource)
    end
  end

  # GET /resource/confirmation?confirmation_token=abcdef
  def show
    self.resource = resource_class.confirm_by_token(params[:confirmation_token])

    if resource.errors.empty?
      set_flash_message(:notice, :confirmed) if is_navigational_format?
      sign_in(resource_name, resource)
      respond_with_navigational(resource){ redirect_to customer_home_path }
    else
      respond_with_navigational(resource.errors, :status => :unprocessable_entity){ render :new }
    end
  end

  protected
  # The path used after resending confirmation instructions.
  def after_resending_confirmation_instructions_path_for(customer)
    home_path
  end

  # The path used after confirmation.
  def after_confirmation_path_for(customer_name, customer)
    after_sign_in_path_for(customer)
  end
end