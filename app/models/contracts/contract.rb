class Contract < ActiveRecord::Base
  include ActiveModel::Validations

  # Associations
  #----------------------------------------------------------------------------
  has_one :ledger, :inverse_of => :Contract, :dependent => :destroy
  
  # Attributes
  #----------------------------------------------------------------------------
  attr_accessible :customer_account_number, :application_number, :contract_number

  # Validations
  #----------------------------------------------------------------------------
  validates :customer_account_number, :presence => true, :immutable => true
  validates :application_number, :presence => true, :immutable => true
  validates :contract_number, :presence => true, :immutable => true
end