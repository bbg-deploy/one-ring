class Customer::BaseController < ::ApplicationController
  layout 'customer_application'
  before_filter :check_scope_conflict

  before_filter :authenticate_customer!
  before_filter :get_customer

  def current_user
    @current_user = current_customer unless current_customer.nil?
  end
  
  def get_customer
    @current_customer = current_customer
  end

  private
  def check_scope_conflict
    redirect_to home_path if (!(current_user.nil?) && (current_customer.nil?))
  end
end