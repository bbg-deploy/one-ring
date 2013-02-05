class PaymentProfileObserver < ActiveRecord::Observer
  observe :payment_profile

  #TODO: Handle Errors gracefully
  def before_create(payment_profile)
    service = AuthorizeNetService.new
    if (payment_profile.cim_customer_payment_profile_id.nil?)
      begin
        payment_profile_id = service.create_cim_customer_payment_profile(payment_profile)
#        puts "Payment_Profile_ID = #{payment_profile_id}"
        payment_profile.set_cim_customer_payment_profile_id("123")
      rescue StandardError => e
        puts "Error: #{e.message}"
        AdminNotificationMailer.report_error("PaymentProfileObserver", "before_create", e.message).deliver
        payment_profile.errors.add(:base, "There was a problem on our end. Please try again a bit later.")
      end
    end
  end
  
  def before_update(payment_profile)
    service = AuthorizeNetService.new
    unless (payment_profile.cim_customer_payment_profile_id.nil?)
      begin
        service.update_cim_customer_payment_profile(payment_profile)
      rescue StandardError => e
        AdminNotificationMailer.report_error("PaymentProfileObserver", "before_update", e.message).deliver
        errors.add(:base, "There was a problem on our end. Please try again a bit later.")
      end
    end
  end

  def before_destroy(payment_profile)
    service = AuthorizeNetService.new
    unless (payment_profile.cim_customer_payment_profile_id.nil?)
      begin
        service.delete_cim_customer_payment_profile(payment_profile)
      rescue StandardError => e
        AdminNotificationMailer.report_error("PaymentProfileObserver", "before_destroy", e.message).deliver
        errors.add(:base, "There was a problem on our end. Please try again a bit later.")
      end
    end
  end
end