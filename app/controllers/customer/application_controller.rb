class Customer::ApplicationController < ::ApplicationController
  layout 'customer_application'

  before_filter :authenticate_customer!
  before_filter :get_customer

  def current_user
    if !(current_customer.nil?)
      @current_user = current_customer
    else
      @current_user = nil
    end
  end
  
  def current_ability
    @current_ability ||= CustomerAbility.new(current_customer)
  end
    
  protected
  def get_customer
    @current_customer = current_customer
  end
  
  private
end