class PaymentProfile < ActiveRecord::Base
  include ActiveModel::Validations
  extend Enumerize
  
  # Associations
  #----------------------------------------------------------------------------
  belongs_to :customer
  has_many :payments

  has_one :billing_address, :as => :addressable, :class_name => 'Address',
                            :conditions => {:address_type => :billing}, :dependent => :destroy, :inverse_of => :addressable
  accepts_nested_attributes_for :billing_address
  has_one :credit_card, :inverse_of => :payment_profile
  accepts_nested_attributes_for :credit_card
  has_one :bank_account, :inverse_of => :payment_profile
  accepts_nested_attributes_for :bank_account
  
  # Attributes
  #----------------------------------------------------------------------------
  attr_accessible :customer, :first_name, :last_name, :payment_type, :last_four_digits,
                  :billing_address_attributes, :credit_card_attributes, :bank_account_attributes

  # Validations
  #----------------------------------------------------------------------------
  before_validation :set_last_four_digits, :on => :create
  enumerize :payment_type, :in => [:credit_card, :bank_account]
  validates :payment_type, :presence => true, :inclusion => { :in => ['credit_card', 'bank_account'] }
  validates :customer, :presence => true, :immutable => true
  validates :cim_customer_payment_profile_id, :immutable => true
  validates :first_name, :presence => true
  validates :last_name, :presence => true
  validates :billing_address, :presence => true
  validates_associated :billing_address
  validates_associated :credit_card, :if => lambda { |payment_profile| payment_profile.try(:payment_type) == "credit_card" }, :on => :create
  validates_associated :bank_account, :if => lambda { |payment_profile| payment_profile.try(:payment_type) == "bank_account" }, :on => :create
  validates :last_four_digits, :presence => true, :length => { :is => 4 }
  validate :has_payment_method, :on => :create
  
  def name
    return "#{self.first_name} #{self.last_name}"
  end

  def authorize_net_billing_details
    return {
      :first_name => self.first_name,
      :last_name => self.last_name,
      :address => self.billing_address.street,
      :city => self.billing_address.city,
      :state => self.billing_address.state,
      :zip => self.billing_address.zip_code,
      :country => self.billing_address.country }
  end

  def authorize_net_payment_details
    if (self.payment_type.credit_card?)
      return self.credit_card.authorize_net_format
    elsif (self.payment_type.bank_account?)
      return self.bank_account.authorize_net_format      
    end
  end

  def set_cim_customer_payment_profile_id(id = nil)
    return false if (id.nil?) || !(id.is_a?(String)) || !(self.cim_customer_payment_profile_id.nil?)
    self.cim_customer_payment_profile_id = id
    return true
  end

  private
  def set_last_four_digits
    if (self.payment_type.nil?)
      errors.add(:payment_type, "cannot be nil")
    elsif (self.payment_type.credit_card?) && !(self.credit_card.nil?)
      if (self.credit_card.valid?)
        self.last_four_digits = self.credit_card.credit_card_number.last(4)
      else
        errors.add(:credit_card, "is invalid.")
      end
    elsif (self.payment_type.bank_account?) && !(self.bank_account.nil?)
      if (self.bank_account.valid?)
        self.last_four_digits = self.bank_account.account_number.last(4)
      else
        errors.add(:bank_account, "is invalid.")
      end
    else
      return false
    end
  end
  
  def has_payment_method
    if (self.payment_type.nil?)
      errors.add(:payment_type, "cannot be nil")
    elsif (self.payment_type.credit_card?) && (self.credit_card.nil?)
      errors.add(:credit_card, "incorrect credit card details")
    elsif (self.payment_type.bank_account?) && (self.bank_account.nil?)
      errors.add(:bank_account, "incorrect bank account details")
    else
      return false
    end
  end
end