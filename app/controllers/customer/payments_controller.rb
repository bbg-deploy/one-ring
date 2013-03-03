class Customer::PaymentsController < Customer::ApplicationController
  before_filter :authenticate_customer!
  before_filter :get_customer
  skip_authorization_check
#  load_and_authorize_resource

  # GET /customer/payments
  #-----------------------------------------------------------------------
  def index
#    payments = Array.new()
#    @current_customer.payment_profiles.each do |payment_profile|
#      payments << payment_profile.payments
#    end
    @payments = nil
    respond_with(:customer, @payments)
  end

  # GET /customer/payments/new
  #-------------------------------------------------------------------
  def new
#    @current_customer = current_customer
#    @payment = Payment.new
    @payment = nil
    respond_with(:customer, @payment)
  end

  # POST /customer/payments
  #-------------------------------------------------------------------
  def create
   # @current_customer = current_customer
  #  params[:payment][:date] = DateTime.now
 #   @payment = Payment.new(params[:payment])
#    if @payment.save
#      cookies[:last_payment_id] = @payment.id
#      flash[:notice] = "Successfully created payment."
#    end
    @payment = nil
    respond_with(:customer, @payment)
  end
end