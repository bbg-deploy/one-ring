class IncomeSource < ActiveRecord::Base
  include ActiveModel::Validations
  extend Enumerize
  
  # Associations
  #----------------------------------------------------------------------------
  belongs_to :customer

  # Accessible Methods
  #----------------------------------------------------------------------------
  attr_accessible :name, :monthly_income

  # Validations
  #----------------------------------------------------------------------------
  validates :customer, :presence => true, :immutable => true
  enumerize :name, :in => [:self_employed, :full_time, :part_time, :disability, :retirement]
  validates :name, :presence => true, :inclusion => { :in => ['self_employed', 'full_time', 'part_time', 'disability', 'retirement'] }
  validates :employer_name, :presence => true
  validates :employer_phone_number, :presence => true
  validates :monthly_income, :presence => true
  
  # Private Methods
  #----------------------------------------------------------------------------
  private
end