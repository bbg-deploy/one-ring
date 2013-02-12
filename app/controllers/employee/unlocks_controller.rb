class Employee::UnlocksController < Devise::UnlocksController
  include ActiveModel::ForbiddenAttributesProtection

  prepend_before_filter :require_no_authentication

  # GET /employee/unlock/new
  def new
    @employee = Employee.new
  end

  # POST /employee/unlock
  def create
    @employee = Employee.send_unlock_instructions(create_employee_params)

    if successfully_sent?(@employee)
      respond_with({}, :location => new_employee_session_path)
    else
      respond_with(@employee)
    end
  end

  # GET /employee/unlock?unlock_token=abcdef
  def show
    @employee = Employee.unlock_access_by_token(params[:unlock_token])

    if @employee.errors.empty?
      set_flash_message :notice, :unlocked
      respond_with_navigational(@employee){ redirect_to new_employee_session_path }
    else
      respond_with_navigational(@employee.errors, :status => :unprocessable_entity){ render :new }
    end
  end

  protected
  def after_sign_in_path_for(employee)
    employee_home_path
  end

  private
  def create_employee_params
    params.require(:employee).permit(:email)
  end
end