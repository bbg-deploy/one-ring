class CreditCardPayment < Credit
  include ActiveModel::Validations
  extend Enumerize

  # Validations
  #----------------------------------------------------------------------------
  validates :payment_profile_id, :presence => true
end
