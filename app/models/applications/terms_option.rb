class TermsOption < ActiveRecord::Base
  include ActiveModel::Validations
  extend Enumerize

  # Association - Application
  #----------------------------------------------------------------------------
  belongs_to :application
  
  # Attributes
  #----------------------------------------------------------------------------
  attr_accessible :application, :payment_frequency, :number_of_payments, :payment_amount, :markup

  # Validations
  #----------------------------------------------------------------------------
  validates :application, :presence => true, :immutable => true
  enumerize :payment_frequency, :in => [:weekly, :biweekly, :semimonthly, :monthly]
  validates :payment_frequency, :presence => true, :inclusion => {:in => ['weekly', 'biweekly', 'semimonthly', 'monthly']}
  validates :number_of_payments, :presence => true,
                                 :numericality => { :greater_than => 0, :allow_nil => false }
  validates :payment_amount, :presence => true,
                             :numericality => { :greater_than => 0, :allow_nil => false },
                             :big_decimal_type => true
  validates :markup, :presence => true,
                     :numericality => { :greater_than => 0, :allow_nil => false },
                     :big_decimal_type => true

  # Public Instance Methods
  #----------------------------------------------------------------------------

  # Private Methods
  #----------------------------------------------------------------------------
  private
end