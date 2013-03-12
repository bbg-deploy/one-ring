class Employee::EmployeesController < Employee::BaseController
  include ActiveModel::ForbiddenAttributesProtection
  before_filter :check_scope_conflict
  load_and_authorize_resource

  # GET /employee/employees
  #-----------------------------------------------------------------------
  def index
    @employees = Employee.all
    respond_with(:employee, @employees)
  end

  # GET /employee/employees/1
  #-------------------------------------------------------------------
  def show
    @employee = Employee.find(params[:id])
    respond_with(:employee, @employee)
  end
  
  # GET /employee/employees/new
  #-------------------------------------------------------------------
  def new
    @employee = Employee.new
    respond_with(:employee, @employee)
  end

  # POST /employee/employees
  #-------------------------------------------------------------------
  def create
    @employee = Employee.new(create_employee_params)
    if @employee.save
      flash[:notice] = "Successfully created employee."  
    else
      flash[:alert] = YAML.load_file("#{Rails.root}/config/locales/devise.en.yml")['en']['devise']['failure']['invalid_data']
    end
    respond_with(:employee, @employee)
  end

  # GET /employee/employees/1/edit
  #-------------------------------------------------------------------
  def edit
    @employee = Employee.find(params[:id])
    respond_with(:employee, @employee)
  end

  # PUT /employee/employees/1
  #-----------------------------------------------------------------
  def update
    @employee = Employee.find(params[:id])
    # Set current password here to allow changes to go through

    if @employee.update_attributes(update_employee_params)
      flash[:notice] = "Successfully updated employee."
    else
      flash[:notice] = "Updating employee failed."
    end
    respond_with(:employee, @employee)
  end
  
  # DELETE /employee/employees/1
  #-------------------------------------------------------------------
  def destroy
    @employee = Employee.find(params[:id])
    @employee.cancel_account!
    flash[:notice] = "Successfully cancelled"
    respond_with @employee, :location => employee_employees_path
  end

  private
  def create_employee_params
    params.require(:employee).permit(
     :username, :password, :password_confirmation, :email, :email_confirmation, 
     :first_name, :middle_name, :last_name, :date_of_birth, :terms_agreement )
  end

  def update_employee_params
    if (params[:employee][:password].blank?) && (params[:employee][:password_confirmation].blank?)
       params[:employee].delete :password
       params[:employee].delete :password_confirmation
    end

    params.require(:employee).permit(
      :username, :password, :password_confirmation, :email, :email_confirmation, 
      :first_name, :middle_name, :last_name, :date_of_birth )
  end

  def check_scope_conflict
    redirect_to employee_scope_conflict_path if (!(current_user.nil?) && (current_employee.nil?))
  end
end