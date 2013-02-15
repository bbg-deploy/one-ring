class Employee::ApplicationController < ::ApplicationController
  layout 'customer_application'

  before_filter :authenticate_employee!
  before_filter :get_employee

  def current_user
    @current_user = current_employee unless current_employee.nil?
  end
  
  def get_employee
    @current_employee = current_employee
  end  
  private
end