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

  # Associations - Omniauth
  #----------------------------------------------------------------------------
  has_many :access_grants, :as => :accessible, :dependent => :destroy

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

  # Associations - Alerts List
  #----------------------------------------------------------------------------
  has_one :alerts_list, :dependent => :destroy, :inverse_of => :customer
  accepts_nested_attributes_for :alerts_list

  # Accessible Methods
  #----------------------------------------------------------------------------
  # TODO: Bring this all back when I have a dedicated server to deploy on
#  attr_accessor :social_security_number
  attr_accessible :first_name, :middle_name, :last_name, :date_of_birth, :social_security_number,
                  :mailing_address, :mailing_address_attributes, 
                  :phone_number, :phone_number_attributes,
                  :alerts_list, :alerts_list_attributes

  # Validations
  #----------------------------------------------------------------------------
  before_validation :generate_account_number, :on => :create
#  before_validation :set_encrypted_ssn
  validates :account_number, :presence => true, :uniqueness => true
  validates :email, :not_credda_email => true
  validates :first_name, :presence => true, :name_format => true
  validates :middle_name, :name_format => true
  validates :last_name, :presence => true, :name_format => true
  validates :date_of_birth, :presence => true
  validates_date :date_of_birth, :before => lambda { 18.years.ago },
                                 :before_message => "must be at least 18 years old"
  validates :social_security_number, :social_security_number_format => true
  validates :social_security_number, :presence => true, :on => :create
#  validates :encrypted_ssn, :presence => true, :symmetric_encryption => true
  validates :mailing_address, :presence => true
  validates_associated :mailing_address
  validates :phone_number, :presence => true
  validates_associated :phone_number
  validates_associated :payment_profiles
  validates :alerts_list, :presence => true
  validates_associated :alerts_list
#  after_save :remove_ssn

  # Methods
  #----------------------------------------------------------------------------
  public
  def name
    return "#{self.first_name} #{self.last_name}"
  end

  def ssn_last_four
#    ssn = SymmetricEncryption.decrypt(self.encrypted_ssn)
    ssn = self.social_security_number
    return "XXX-XX-#{ssn.last(4)}"
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

  private
  def generate_account_number
    if self.account_number.nil?
      begin
        token = 'UCU' + SecureRandom.hex(5).upcase
      end if Customer.where({:account_number => token}).empty?
      self.account_number = token
    end
  end

  def set_encrypted_ssn
    self.encrypted_ssn = SymmetricEncryption.encrypt(self.social_security_number) unless self.social_security_number.nil?
  end
  
  def remove_ssn
    self.social_security_number = nil
  end
end