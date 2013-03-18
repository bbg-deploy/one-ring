class Employee::RegistrationsController < Devise::RegistrationsController
  include ActiveModel::ForbiddenAttributesProtection
  layout 'employee_layout', :only => [:edit, :update, :destroy, :cancel_account]

  # Authentication filters
  prepend_before_filter :require_no_authentication, :only => [:cancel]
  prepend_before_filter :authenticate_scope!, :only => [:edit, :update, :destroy, :cancel_account]
  before_filter :check_scope_conflict

  # GET /employee/sign_up
  def new
    path = current_employee.nil? ? home_path : employee_home_path
    redirect_to path    
  end

  # POST /employee
  def create
    path = current_employee.nil? ? home_path : employee_home_path
    redirect_to path
  end

  # GET /employee/edit
  def edit
    @employee = current_employee
    respond_with @employee
  end
  
  # PUT /employee
  def update
    @employee = current_employee
    prev_unconfirmed_email = @employee.unconfirmed_email if @employee.respond_to?(:unconfirmed_email)

    if @employee.update_with_password(update_employee_params)
      flash_key = update_needs_confirmation?(@employee, prev_unconfirmed_email) ? :update_needs_confirmation : :updated
      set_flash_message :notice, flash_key
      sign_in :employee, @employee, :bypass => true
      respond_with @employee, :location => employee_home_path
    else
      # Set passwords to blank before we redirect
      flash[:alert] = YAML.load_file("#{Rails.root}/config/locales/devise.en.yml")['en']['devise']['failure']['invalid_data']
      clean_up_passwords @employee
      respond_with @employee
    end
  end

  # DELETE /employee
  def destroy
    # Don't actually destroy the customer object, just set it to 'cancelled'
    @employee = current_employee
    @employee.cancel_account!
    Devise.sign_out_all_scopes ? sign_out : sign_out(:employee)
    set_flash_message :notice, :destroyed
    respond_with @employee, :location => home_path
  end

  # DELETE /employee
  def destroy
    @employee = current_employee
    if @employee.destroy
      Devise.sign_out_all_scopes ? sign_out : sign_out(:employee)
      set_flash_message :notice, :destroyed
    else
      set_flash_message :alert, :cannot_be_destroyed
    end
    respond_with @employee, :location => home_path
  end

  # DELETE /employee/cancel_account
  def cancel_account
    @employee = current_employee
    if @employee.cancel_account
      Devise.sign_out_all_scopes ? sign_out : sign_out(:employee)
      set_flash_message :notice, :cancelled
    else
      set_flash_message :alert, :cannot_be_cancelled
    end    
    respond_with @employee, :location => home_path
  end

  # GET /employee/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  def cancel
    expire_session_data_after_sign_in!
    redirect_to new_employee_registration_path
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
    params.require(:employee).permit(
     :username, :password, :password_confirmation, :email, :email_confirmation, 
     :first_name, :middle_name, :last_name, :date_of_birth, :terms_agreement )
  end

  def update_employee_params
    params.require(:employee).permit(
      :username, :password, :password_confirmation, :current_password, :email, :email_confirmation, 
      :first_name, :middle_name, :last_name, :date_of_birth )
  end
end