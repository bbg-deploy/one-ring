class Identification < ActiveRecord::Base
  include ActiveModel::Validations
  extend Enumerize
   
  # Associations
  #----------------------------------------------------------------------------
  belongs_to :customer

  # Attributes
  #----------------------------------------------------------------------------
  attr_accessible :identification_type, :authority, :identification_number
                  
  # Validations
  #----------------------------------------------------------------------------
  validates :customer, :presence => true, :immutable => true
  enumerize :identification_type, :in => [:drivers_license, :state_id, :military_id, :passport, :college_id]
  validates :identification_type, :presence => true, :inclusion => { :in => ['drivers_license', 'state_id', 'military_id', 'passport', 'college_id'] }
  validates :authority, :presence => true
  validates :identification_number, :presence => true

  private
end