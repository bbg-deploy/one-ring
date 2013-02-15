class EmployeeRole < ActiveRecord::Base
  include ActiveModel::Validations  
  has_many :employees, :through => :employee_role_assignments
  
#  scopify
end
