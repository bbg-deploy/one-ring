class Organization < ActiveRecord::Base
  include ActiveModel::Validations
    
  # Associations - Profile
  #----------------------------------------------------------------------------
  has_many :stores, :inverse_of => :organization

  # Use attr_accessible to control security
  #----------------------------------------------------  
  attr_accessible :name, :website

  # Validate fields before saving them to the DB
  # Custom Validators are found in lib/validators
  #----------------------------------------------------  
  validates :name, :presence => true
  validates :website, :presence => true

  # Public
  #----------------------------------------------------------------------------
  public
  
  # Private Methods
  #----------------------------------------------------------------------------
  private
end