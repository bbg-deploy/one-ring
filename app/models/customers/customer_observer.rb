class CustomerObserver < ActiveRecord::Observer
  observe :customer

  #TODO: Handle Errors gracefully
  def before_create(customer)
    service = AuthorizeNetService.new
    if (customer.cim_customer_profile_id.nil?)
      service.create_cim_customer_profile(customer)
    end
  end
  
  def before_update(customer)
    service = AuthorizeNetService.new
    if (customer.cim_customer_profile_id.nil?)
      service.create_cim_customer_profile(customer)
    else
      service.update_cim_customer_profile(customer)
    end
  end

  def before_destroy(customer)
    service = AuthorizeNetService.new
    unless (customer.cim_customer_profile_id.nil?)
      service.delete_cim_customer_profile(customer)
    end
  end

  def after_save(customer)
    begin
      AdminNotificationMailer.report_new_user(customer).deliver
    rescue => e
      puts "AdminNotificationMailer error.  New customer email not sent."
    end
  end
end