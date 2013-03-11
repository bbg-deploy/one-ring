class Payment < ActiveRecord::Base
=begin
  THIS IS JUST FOR REFERENCE
  
  
  include ActiveModel::Validations
  include Creditable
  is_creditable

  # Mass Assignable Attributes
  #----------------------------------------------------------------------------
  attr_accessible :contract_type, :contract_id

  # Validations
  #----------------------------------------------------------------------------
  enumerize :contract_type, in: [:lease_to_own]
  validates :contract_id, :presence => true, :immutable => true
  validates :contract_type, :presence => true, :inclusion => { :in => ['lease_to_own'] }, :immutable => true

  enumerize :payment_type, in: [:credit_card, :bank_transfer]
  validates :payment_type, :presence => true, :inclusion => { :in => ['credit_card', 'bank_transfer'] }, :immutable => true
  
  # Public Instance Methods
  #----------------------------------------------------------------------------
  private
=end
end