class Customer::PaymentsController < Customer::BaseController
  skip_authorization_check
#  load_and_authorize_resource

  # GET /customer/payments
  #-------------------------------------------------------------------
  def index
    @payments = Payment.where(:customer_id => current_customer.id)
    respond_with(:customer, @payments)
  end

  # GET /customer/payments/new
  #-------------------------------------------------------------------
  def new
    @payment_profiles = current_customer.payment_profiles
    @payment = Payment.new
    @payment.customer = current_customer
    respond_with(:customer, @payment)
  end

  # POST /customer/payments
  #-------------------------------------------------------------------
  def create
    @payment = Payment.new(params[:payment])
    @payment.customer = current_customer
    if @payment.save
      flash[:notice] = "Successfully created payment."
    else
      flash[:alert] = YAML.load_file("#{Rails.root}/config/locales/devise.en.yml")['en']['devise']['failure']['invalid_data']
    end
    respond_with @payment, :location => customer_payments_path
  end
end