class EmployeeRole < ActiveRecord::Base
  include ActiveModel::Validations  
  has_many :employees, :through => :employee_role_assignments
  
  attr_accessible :name
  
  validates :name, :presence => true, :uniqueness => true
  
  # Public Methods
  public
  def has_employee?(employee)
    return self.employees.include?(employee)
  end
  
  private
end
