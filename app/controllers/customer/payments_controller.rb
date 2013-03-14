class Customer::PaymentsController < Customer::BaseController
  skip_authorization_check
#  load_and_authorize_resource

  # GET /customer/payments
  #-------------------------------------------------------------------
  def index
    @payment = Payment.all
    respond_with(:customer, @payment)
  end

  # GET /customer/payments/new
  #-------------------------------------------------------------------
  def new
    @payment = Payment.new
    respond_with(:customer, @payment)
  end

  # POST /customer/payments
  #-------------------------------------------------------------------
  def create
    @payment = Payment.new(params[:payment])
    if @payment.save
      flash[:notice] = "Successfully created payment."
    end
    respond_with(:customer, @payment)
  end
end