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

  # Associations
  #----------------------------------------------------------------------------
  has_many :employee_roles, :through => :employee_role_assignments

  # Accessible Methods
  #----------------------------------------------------------------------------
  attr_accessible :first_name, :middle_name, :last_name, :date_of_birth

  # Validations
  #----------------------------------------------------------------------------
  before_validation :generate_account_number, :on => :create
  validates :account_number, :presence => true, :uniqueness => true
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

  def active_for_authentication?
    super && self.cancelled_at.nil?
  end

  def inactive_message 
    if cancelled? 
      :cancelled
    else 
      super # Use whatever other message 
    end 
  end
  
  def status
    return "unconfirmed" if !self.confirmed?
    return "cancelled" if self.cancelled?
    return "active"
  end

  def deletable?
    return false
  end
  
  def destroy
    self.deletable? ? super : false
  end

  def cancellable?
    return true
  end

  private
  def generate_account_number
    if self.account_number.nil?
      begin
        token = 'UEM' + SecureRandom.hex(5).upcase
      end if Employee.where({:account_number => token}).empty?
      self.account_number = token
    end
  end
end