class Installment < ActiveRecord::Base
=begin
  THIS IS JUST FOR REFERENCE

  include ActiveModel::Validations
  extend Enumerize
  include Debitable
  is_debitable


  # Mass Assignable Attributes
  #----------------------------------------------------------------------------
  attr_accessible :contract_type, :contract_id, :due_date

  # Validations
  #----------------------------------------------------------------------------
  enumerize :contract_type, in: [:lease_to_own]
  validates :contract_id, :presence => true, :immutable => true
  validates :contract_type, :presence => true, :inclusion => { :in => ['lease_to_own'] }, :immutable => true
  validates :due_date, :presence => true
  
  # State Machine
  #----------------------------------------------------------------------------
  state_machine :state, :initial => :unpaid do
    event :mark_unpaid do
      transition :paid => :unpaid
    end

    event :mark_paid do
      transition :unpaid => :paid
    end
  end

  # Private Instance Methods
  #----------------------------------------------------------------------------
  private
=end
end