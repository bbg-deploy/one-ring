class AdminAssignment < ActiveRecord::Base
  include ActiveModel::Validations

  # Associations
  #----------------------------------------------------------------------------
  belongs_to :admin
  belongs_to :admin_role  
  
  # Validations
  #----------------------------------------------------------------------------
  validates :admin, :presence => true, :immutable => true
  validates :admin_role, :presence => true, :immutable => true
end
