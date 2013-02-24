class Employee::PasswordsController < Devise::PasswordsController
  include ActiveModel::ForbiddenAttributesProtection

  prepend_before_filter :require_no_authentication
  # Render the #edit only if coming from a reset password email link
  append_before_filter :assert_reset_token_passed, :only => :edit
  before_filter :check_scope_conflict

  # GET /employee/password/new
  def new
    @employee = Employee.new
  end

  # POST /employee/password
  def create
    @employee = Employee.send_reset_password_instructions(create_employee_params)

    if successfully_sent?(@employee)
      respond_with({}, :location => new_employee_session_path)
    else
      respond_with(@employee)
    end
  end

  # GET /employee/password/edit?reset_password_token=abcdef
  def edit
    @employee = Employee.find_or_initialize_with_error_by(:reset_password_token, params[:reset_password_token])
    if @employee.errors.empty?
      respond_with(@employee)
    else
      set_flash_message :alert, :invalid_reset_token
      redirect_to new_employee_session_path
    end
  end

  # PUT /employee/password
  def update
    @employee = Employee.reset_password_by_token(update_employee_params)

    if @employee.errors.empty?
      @employee.unlock_access! if unlockable?(@employee)
      flash_message = @employee.active_for_authentication? ? :updated : :updated_not_active
      set_flash_message(:notice, flash_message)
      sign_in(:employee, @employee)
      respond_with @employee, :location => employee_home_path
    else
      respond_with @employee
    end
  end

  protected
  def check_scope_conflict
    redirect_to employee_scope_conflict_path if (!(current_user.nil?) && (current_employee.nil?))
  end

  def after_sign_in_path_for(employee)
    employee_home_path
  end

  # Check if a reset_password_token is provided in the request
  def assert_reset_token_passed
    if params[:reset_password_token].blank?
      set_flash_message(:error, :no_token)
      redirect_to new_employee_session_path
    end
  end

  # Check if proper Lockable module methods are present & unlock strategy
  # allows to unlock employee on password reset
  def unlockable?(employee)
    employee.respond_to?(:unlock_access!) &&
      employee.respond_to?(:unlock_strategy_enabled?) &&
      employee.unlock_strategy_enabled?(:email)
  end

  private
  def create_employee_params
    params.require(:employee).permit(:email)
  end

  def update_employee_params
    params.require(:employee).permit(:reset_password_token, :password, :password_confirmation)
  end
end