class Customer::CreditCardsController < Customer::BaseController
  include ActiveModel::ForbiddenAttributesProtection
  load_and_authorize_resource

  # GET /customer/credit_cards
  #-----------------------------------------------------------------------
  def index
    @credit_cards = current_customer.payment_profiles
    respond_with(:customer, @credit_cards)
  end
  
  # GET /customer/credit_cards/new
  #-------------------------------------------------------------------
  def new
    @credit_card = PaymentProfile.new
    @credit_card.build_credit_card
    @credit_card.build_billing_address
    respond_with(:customer, @credit_card)
  end

  # POST /customer/credit_cards
  #-------------------------------------------------------------------
  def create
    @credit_card = PaymentProfile.new(create_payment_profile_params)
    @credit_card.customer = current_customer
    if @credit_card.save
      flash[:notice] = "Successfully linked credit card."  
    else
      flash[:alert] = YAML.load_file("#{Rails.root}/config/locales/devise.en.yml")['en']['devise']['failure']['invalid_data']
    end
    respond_with(:customer, @credit_card)
  end

  # GET /customer/payment_profiles/1/edit
  #-------------------------------------------------------------------
  def edit
    @credit_card = PaymentProfile.find(params[:id])
    respond_with(:customer, @credit_card)
  end

  # PUT /customer/payment_profiles/1
  #-----------------------------------------------------------------
  def update
    @credit_card = PaymentProfile.find(params[:id])
    
    if @credit_card.update_attributes(update_payment_profile_params)
      flash[:notice] = "Successfully updated credit card."
    else
      flash[:notice] = "Updating payment profile failed."
    end
    respond_with(:customer, @credit_card)
  end
  
  # DELETE /customer/payment_profiles/1
  #-------------------------------------------------------------------
  def destroy
    @credit_card = PaymentProfile.find(params[:id])
    @credit_card.destroy
    flash[:notice] = "Successfully deleted payment profile."  
    respond_with(:customer, @credit_card)
  end

  private
  def create_credit_card_params
    params.require(:credit_card).permit(
      :first_name, :last_name, :payment_type, 
      {:billing_address_attributes  => [:street, :city, :state, :zip_code, :country]}, 
      {:credit_card_attributes  => [:brand, :credit_card_number, :expiration_date, :ccv_number]} )
  end

  def update_credit_card_params
    params.require(:credit_card).permit(
      :first_name, :last_name, :payment_type, 
      {:billing_address_attributes  => [:street, :city, :state, :zip_code, :country]}, 
      {:credit_card_attributes  => [:brand, :credit_card_number, :expiration_date, :ccv_number]} )
  end
end