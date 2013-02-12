class Employee < ActiveRecord::Base
  include ActiveModel::Validations
  include Authentication

  has_friendly_username
  is_authenticatable
  is_registerable
  is_confirmable
  is_recoverable
  is_lockable
  is_rememberable
  is_timeoutable
  is_terms_agreeable

  def devise_mailer
    EmployeeAuthenticationMailer
  end

  # Accessible Methods
  #----------------------------------------------------------------------------
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

  # Methods
  #----------------------------------------------------------------------------
  public
  # Views Helpers (Probably should go in a helpers file)
  #----------------------------------------------------
  def name
    return "#{self.first_name} #{self.last_name}"
  end

  private
end