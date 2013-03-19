class PaymentObserver < ActiveRecord::Observer
  observe :payment

  # Before Create
  #----------------------------------------------------------------------------
  def before_create(payment)
    service = AuthorizeNetService.new
    unless (payment.payment_profile.nil?)
      begin
        service.create_cim_customer_profile_transaction(payment.payment_profile, payment.amount)
      rescue => e
        AdminNotificationMailer.authorize_net_error(payment, e).deliver
        return false
      end
    end
  end
  
  # After Create
  #----------------------------------------------------------------------------
  def after_create(payment)
#    AdminNotificationMailer.new_user(customer).deliver
  end
end