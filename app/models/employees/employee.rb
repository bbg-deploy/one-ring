class Employee < ActiveRecord::Base
  include ActiveModel::Validations
  include Authentication #Authentication concern found in lib/concerns
  has_friendly_username
  is_authenticatable
  is_registerable
  is_recoverable
  is_lockable
  is_rememberable
  is_timeoutable
  is_terms_agreeable  
  
  def devise_mailer
    EmployeeAuthenticationMailer
  end
  
  # Assignments
  #----------------------------------------------------------------------------
#  has_many :employee_assignments, :dependent => :destroy, :inverse_of => :employee
#  has_many :employee_roles, :through => :employee_assignments

  # Attributes
  #----------------------------------------------------------------------------
  #TODO: Is login not defind in the Concern?
  attr_accessible :login
  attr_accessible :first_name, :middle_name, :last_name, :date_of_birth

  # Validations
  #----------------------------------------------------------------------------
  validates :email, :credda_email => true
  validates :first_name, :presence => true, :name_format => true
  validates :middle_name, :name_format => true
  validates :last_name, :presence => true, :name_format => true
  validates :date_of_birth, :presence => true
  validates_date :date_of_birth, :before => lambda { 18.years.ago },
                                 :before_message => "must be at least 18 years old"

  # Public Methods
  #----------------------------------------------------------------------------
  def role?(role)
#    unless self.roles.find_by_name(role.to_s).nil?
#      return true
#    else
      return false
#    end
  end
end