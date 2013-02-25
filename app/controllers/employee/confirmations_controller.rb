class Employee::ConfirmationsController < Devise::ConfirmationsController
  include ActiveModel::ForbiddenAttributesProtection

  # Authentication filters
  prepend_before_filter :require_no_authentication, :only => [ :new, :create, :show ]
  before_filter :check_scope_conflict

  # GET /employee/confirmation/new
  def new
    @employee = Employee.new
  end

  # POST /employee/confirmation
  def create
    @employee = Employee.send_confirmation_instructions(create_employee_params)

    if successfully_sent?(@employee)
      respond_with({}, :location => home_path)
    else
      respond_with(@employee)
    end
  end

  # GET /employee/confirmation?confirmation_token=abcdef
  def show
    @employee = Employee.confirm_by_token(params[:confirmation_token])

    if @employee.errors.empty?
      set_flash_message(:notice, :confirmed) if is_navigational_format?
      sign_in(:employee, @employee)
      redirect_to employee_home_path
    else
      respond_with_navigational(@employee.errors, :status => :unprocessable_entity){ render :new }
    end
  end

  protected
  def check_scope_conflict
    redirect_to employee_scope_conflict_path if (!(current_user.nil?) && (current_employee.nil?))
  end

  def after_sign_in_path_for(employee)
    employee_home_path
  end

  private
  def create_employee_params
    params.require(:employee).permit(:email)
  end
end