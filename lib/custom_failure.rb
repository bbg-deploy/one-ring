class CustomFailure < Devise::FailureApp
=begin
  def redirect_url
#    return super unless [:customer, :store, :employee].include?(scope)
    
#    if (scope == :customer) && 
#      new_customer_session_path
#    elsif (scope == :store)
#      new_store_session_path
#    elsif (scope == :employee)
#      new_employee_session_path
#    else
#      return super
#    end
#     #make it specific to a scope
#     new_user_session_url(:subdomain => 'secure')
  end

  def redirect
      store_location!
      if flash[:timedout] && flash[:alert]
        flash.keep(:timedout)
        flash.keep(:alert)
      else
        flash[:alert] = i18n_message
      end
      redirect_to redirect_url
    end

  def respond
    if http_auth?
      http_auth
    else
      redirect
    end
  end
=end
end