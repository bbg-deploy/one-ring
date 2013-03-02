class CustomerObserver < ActiveRecord::Observer
  observe :customer

  # Before Create
  #----------------------------------------------------------------------------
  def before_create(customer)
    service = AuthorizeNetService.new
    if (customer.cim_customer_profile_id.nil?)
      begin
        service.create_cim_customer_profile(customer)
      rescue => e
        AdminNotificationMailer.authorize_net_error(customer, e).deliver
        return false
      end
    end
  end
  
  # Before Update
  #----------------------------------------------------------------------------
  def before_update(customer)
    service = AuthorizeNetService.new
    unless (customer.cim_customer_profile_id.nil?)
      begin
        service.update_cim_customer_profile(customer)
      rescue => e
        AdminNotificationMailer.authorize_net_error(customer, e).deliver
        return false
      end
    end
  end

  # Before Destroy
  #----------------------------------------------------------------------------
  def before_destroy(customer)
    service = AuthorizeNetService.new
    unless (customer.cim_customer_profile_id.nil?)
      begin
        service.delete_cim_customer_profile(customer)
      rescue => e
        AdminNotificationMailer.authorize_net_error(customer, e).deliver
        return false
      end
    end
  end

  # After Commit
  #----------------------------------------------------------------------------
  def after_create(customer)
    AdminNotificationMailer.new_user(customer).deliver
  end
end