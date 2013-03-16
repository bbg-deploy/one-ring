class EmployeeObserver < ActiveRecord::Observer
  observe :employee

  # After Create
  #----------------------------------------------------------------------------
  def after_create(employee)
    AdminNotificationMailer.new_user(employee).deliver
  end
end