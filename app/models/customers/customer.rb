class Customer < ActiveRecord::Base
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
    CustomerAuthenticationMailer
  end

  # Associations - Contact Information
  #----------------------------------------------------------------------------
  has_one :mailing_address, :as => :addressable, :class_name => 'Address', 
                            :conditions => {:address_type => :mailing}, :dependent => :destroy, :inverse_of => :addressable
  accepts_nested_attributes_for :mailing_address
  
  has_one :phone_number, :as => :phonable, :class_name => 'PhoneNumber', :dependent => :destroy, :inverse_of => :phonable
  accepts_nested_attributes_for :phone_number

  # Associations - Payment Profiles
  #----------------------------------------------------------------------------
  has_many :payment_profiles, :dependent => :destroy, :inverse_of => :customer
  accepts_nested_attributes_for :payment_profiles

  # Accessible Methods
  #----------------------------------------------------------------------------
  attr_accessible :first_name, :middle_name, :last_name, :date_of_birth, :social_security_number,
                  :mailing_address, :mailing_address_attributes, 
                  :phone_number, :phone_number_attributes

  # Validations
  #----------------------------------------------------------------------------
  validates :email, :not_credda_email => true
  validates :first_name, :presence => true, :name_format => true
  validates :middle_name, :name_format => true
  validates :last_name, :presence => true, :name_format => true
  validates :date_of_birth, :presence => true
  validates_date :date_of_birth, :before => lambda { 18.years.ago },
                                 :before_message => "must be at least 18 years old"
  validates :social_security_number, :presence => true,
                                     :uniqueness => true,
                                     :social_security_number_format => true
  validates :mailing_address, :presence => true
  validates_associated :mailing_address
  validates :phone_number, :presence => true
  validates_associated :phone_number
  validates_associated :payment_profiles

  # Methods
  #----------------------------------------------------------------------------
  public
  # Views Helpers (Probably should go in a helpers file)
  #----------------------------------------------------
  def name
    return "#{self.first_name} #{self.last_name}"
  end
  
  # Non-Views Methods
  #----------------------------------------------------
  def cancel_account
    self.cancelled_at = Time.now
  end
  
  def cancelled?
    return self.cancelled_at.nil?
  end

  def active_for_authentication?
    super && !cancelled_at
  end

  private
end