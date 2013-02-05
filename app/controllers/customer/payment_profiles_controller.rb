class Customer::PaymentProfilesController < Customer::ApplicationController
  before_filter :authenticate_customer!
  before_filter :get_customer
#  load_and_authorize_resource

  # GET /customer/payment_profiles
  #-----------------------------------------------------------------------
  def index
    @current_customer = current_customer
    @payment_profiles = @current_customer.payment_profiles
    respond_with(:customer, @payment_profiles)
  end

  # GET /customer/payment_profiles/1
  #-------------------------------------------------------------------
  def show
    @current_customer = current_customer
    @payment_profile = PaymentProfile.find(params[:id])
    respond_with(:customer, @payment_profiles)
  end
  
  # GET /customer/payment_profiles/new
  #-------------------------------------------------------------------
  def new
    @current_customer = current_customer
    @payment_profile = PaymentProfile.new
    respond_with(:customer, @payment_profile)
  end

  # POST /customer/payment_profiles
  #-------------------------------------------------------------------
  def create
    @current_customer = current_customer
    params[:payment_profile][:customer] = Customer.find(@current_customer.id)
    @payment_profile = PaymentProfile.new(params[:payment_profile])
    if @payment_profile.save
      cookies[:last_payment_profile_id] = @payment_profile.id
      flash[:notice] = "Successfully created payment profile."  
    end
    respond_with(:customer, @payment_profile)
  end

  # GET /customer/payment_profiles/1/edit
  #-------------------------------------------------------------------
  def edit
    @current_customer = current_customer
    @payment_profile = PaymentProfile.find(params[:id])
    respond_with(:customer, @payment_profile)
  end

  # PUT /customer/payment_profiles/1
  #-----------------------------------------------------------------
  def update
    @current_customer = current_customer
    @payment_profile = PaymentProfile.find(params[:id])
    
    if @payment_profile.update_attributes(params[:payment_profile])
      flash[:notice] = "Successfully updated payment profile."
    else
      flash[:notice] = "Updating payment profile failed."
    end
    respond_with(:customer, @payment_profile)
  end
  
  # DELETE /customer/payment_profiles/1
  #-------------------------------------------------------------------
  def destroy
    @current_customer = current_customer
    @payment_profile = PaymentProfile.find(params[:id])
    @payment_profile.destroy
    flash[:notice] = "Successfully deleted payment profile."  
    respond_with(:customer, @payment_profile)
  end
end