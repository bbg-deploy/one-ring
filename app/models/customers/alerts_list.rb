class AlertsList < ActiveRecord::Base
  include ActiveModel::Validations
  extend Enumerize
   
  # Associations
  #----------------------------------------------------------------------------
  belongs_to :customer

  # Attributes
  #----------------------------------------------------------------------------
  attr_accessible :customer, :mail, :email, :sms, :phone
                  
  # Validations
  #----------------------------------------------------------------------------
  validates :customer, :presence => true, :immutable => true
  validates :mail, :inclusion => { :in => [true, false] }
  validates :email, :inclusion => { :in => [true, false] }
  validates :sms, :inclusion => { :in => [true, false] }
  validates :phone, :inclusion => { :in => [true, false] }

  # Public Methods
  #----------------------------------------------------------------------------
  def mailable?
    return self.mail
  end

  def emailable?
    return self.email
  end

  def smsable?
    return self.sms
  end

  def phonable?
    return self.phone
  end

  private
end