class Customer::ApplicationController < ::ApplicationController
  layout 'customer_application'

  before_filter :authenticate_customer!
  before_filter :get_customer

  def current_user
    @current_user = current_customer unless current_customer.nil?
  end
  
  def get_customer
    @current_customer = current_customer
  end  
  private
end