class Customer::PaymentsController < Customer::BaseController
  before_filter :authenticate_customer!
  before_filter :get_customer
  skip_authorization_check
#  load_and_authorize_resource

  # GET /customer/payments/new
  #-------------------------------------------------------------------
  def new
    @payment = Payment.new
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