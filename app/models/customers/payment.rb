class Payment < ActiveRecord::Base
  include ActiveModel::Validations

  belongs_to :customer
  belongs_to :payment_profile
  attr_accessible :customer, :payment_profile, :amount

  before_validation :set_cim_customer_payment_profile_id
  validates :customer, :presence => true, :immutable => true
  validates :payment_profile, :presence => true, :immutable => true
  validates :amount, :presence => true,
                     :numericality => { :greater_than => 0, :allow_nil => false },
                     :big_decimal_type => true
  validate :payment_profile_belongs_to_customer

  # Public Instance Methods
  #----------------------------------------------------------------------------

  # Private Methods
  #----------------------------------------------------------------------------
  private
  def set_cim_customer_payment_profile_id
    self.cim_customer_payment_profile_id = self.payment_profile.cim_customer_payment_profile_id unless self.payment_profile.nil?
  end
  
  def payment_profile_belongs_to_customer
    unless (self.customer.nil?) || (self.payment_profile.nil?)
      errors.add(:payment_profile, 'does not belong to you') unless self.customer == self.payment_profile.customer
    end
  end
end