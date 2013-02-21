class Customer::PaymentProfilesController < Customer::ApplicationController
  include ActiveModel::ForbiddenAttributesProtection
  load_and_authorize_resource

  # GET /customer/payment_profiles
  #-----------------------------------------------------------------------
  def index
    @payment_profiles = current_customer.payment_profiles
    respond_with(:customer, @payment_profiles)
  end

  # GET /customer/payment_profiles/1
  #-------------------------------------------------------------------
  def show
    @payment_profile = PaymentProfile.find(params[:id])
    respond_with(:customer, @payment_profiles)
  end
  
  # GET /customer/payment_profiles/new
  #-------------------------------------------------------------------
  def new
    @payment_profile = PaymentProfile.new
    @payment_profile.build_credit_card
    @payment_profile.build_bank_account
    @payment_profile.build_billing_address
    respond_with(:customer, @payment_profile)
  end

  # POST /customer/payment_profiles
  #-------------------------------------------------------------------
  def create
    @payment_profile = PaymentProfile.new(create_payment_profile_params)
    @payment_profile.customer = current_customer
    if @payment_profile.save
      cookies[:last_payment_profile_id] = @payment_profile.id
      flash[:notice] = "Successfully created payment profile."  
    end
    respond_with(:customer, @payment_profile)
  end

  # GET /customer/payment_profiles/1/edit
  #-------------------------------------------------------------------
  def edit
    @payment_profile = PaymentProfile.find(params[:id])
    respond_with(:customer, @payment_profile)
  end

  # PUT /customer/payment_profiles/1
  #-----------------------------------------------------------------
  def update
    @payment_profile = PaymentProfile.find(params[:id])
    
    if @payment_profile.update_attributes(update_payment_profile_params)
      flash[:notice] = "Successfully updated payment profile."
    else
      flash[:notice] = "Updating payment profile failed."
    end
    respond_with(:customer, @payment_profile)
  end
  
  # DELETE /customer/payment_profiles/1
  #-------------------------------------------------------------------
  def destroy
    @payment_profile = PaymentProfile.find(params[:id])
    @payment_profile.destroy
    flash[:notice] = "Successfully deleted payment profile."  
    respond_with(:customer, @payment_profile)
  end

  private
  def create_payment_profile_params
    params.require(:payment_profile).permit(:first_name, :last_name, :payment_type, {:billing_address_attributes  => [:street, :city, :state, :zip_code, :country]}, {:credit_card_attributes  => [:brand, :credit_card_number, :expiration_date, :ccv_number]}, {:bank_account_attributes  => [:account_holder, :account_type, :routing_number, :account_number]})
  end

  def update_payment_profile_params
    params.require(:payment_profile).permit(:first_name, :last_name, :payment_type, {:billing_address_attributes  => [:street, :city, :state, :zip_code, :country]}, {:credit_card_attributes  => [:brand, :credit_card_number, :expiration_date, :ccv_number]}, {:bank_account_attributes  => [:account_holder, :account_type, :routing_number, :account_number]})
  end
end