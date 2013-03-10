class Store < ActiveRecord::Base
  include ActiveModel::Validations
  include Authentication #Authentication concern found in lib/concerns
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
    StoreAuthenticationMailer
  end
    
  # Associations - Organization
  #----------------------------------------------------------------------------
  belongs_to :organization

  # Associations - Profile
  #----------------------------------------------------------------------------
  has_many :addresses, :as => :addressable, :class_name => 'Address', 
                       :conditions => {:address_type => :store}, :dependent => :destroy, :inverse_of => :addressable
  accepts_nested_attributes_for :addresses
                       
  has_many :phone_numbers, :as => :phonable, :class_name => 'PhoneNumber', :dependent => :destroy, :inverse_of => :phonable
  accepts_nested_attributes_for :phone_numbers

  # Use attr_accessible to control security
  #----------------------------------------------------  
  attr_accessible :organization, :name, :employer_identification_number, 
                  :addresses, :addresses_attributes,
                  :phone_numbers, :phone_numbers_attributes

  # Validate fields before saving them to the DB
  # Custom Validators are found in lib/validators
  #----------------------------------------------------  
  before_validation :generate_account_number, :on => :create
  validates :account_number, :presence => true, :uniqueness => true
  validates :email, :not_credda_email => true
  validates :name, :presence => true
  validates :employer_identification_number, :presence => true,
                                             :uniqueness => true, 
                                             :employer_identification_number_format => true,
                                             :allow_nil => true
  validates :addresses, :presence => true
  validates_associated :addresses
  validates :phone_numbers, :presence => true
  validates_associated :phone_numbers

  # Public
  #----------------------------------------------------------------------------
  public  
  def active_for_authentication?
    super && self.cancelled_at.nil? && self.approved?
  end

  def approve_account!
    self.approved_at = DateTime.now
    self.save!
  end

  def approved?
    return !self.approved_at.nil?
  end

  def status
    return "unapproved" if !self.approved?
    return "unconfirmed" if !self.confirmed?
    return "cancelled" if self.cancelled?
    return "active"
  end

  def inactive_message 
    if !approved? 
      :not_approved 
    elsif cancelled? 
      :cancelled
    else 
      super # Use whatever other message 
    end 
  end

  # Private Methods
  #----------------------------------------------------------------------------
  private
  def generate_account_number
    if self.account_number.nil?
      begin
        token = 'UST' + SecureRandom.hex(5).upcase
      end if Store.where({:account_number => token}).empty?
      self.account_number = token
    end
  end
end