class Payment < Credit
  include ActiveModel::Validations
  extend Enumerize

  # Validations
  #----------------------------------------------------------------------------
  validates :cim_payment_profile_id, :presence => true
end
