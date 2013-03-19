class Customer::ApplicationsController < Customer::BaseController
  include ActiveModel::ForbiddenAttributesProtection
  load_and_authorize_resource

  # GET /store/applications
  #-----------------------------------------------------------------------
  def index
    @applications = Application.all
    respond_with(:customer, @applications)
  end

  # GET /store/applications/1
  #-------------------------------------------------------------------
  def show
    @application = Application.find(params[:id])
    respond_with(:customer, @application)
  end
  
  # PUT /store/applications/1/claim
  #-------------------------------------------------------------------
  def claim
    @application = Application.find(params[:id])
    @application.customer_account_number = current_customer.account_number

    if @application.claim
      flash[:notice] = "Successfully claimed application."
    else
      flash[:alert] = YAML.load_file("#{Rails.root}/config/locales/devise.en.yml")['en']['devise']['failure']['invalid_data']
    end
    respond_with(:customer, @application)
  end

  # GET /store/applications/1/edit
  #-------------------------------------------------------------------
  def edit
    @product_types = ["Tire"]
    @application = Application.find(params[:id])
    respond_with(:customer, @application)
  end

  # PUT /employee/applications/1
  #-----------------------------------------------------------------
  def update
    @product_types = ["Tire"]
    @application = Application.find(params[:id])

    if @application.update_attributes(update_application_params)
      flash[:notice] = "Successfully updated application."
      if @application.submit
        credit_decision = CreditDecision.new(:application => @application)
        if credit_decision.save
          @application.approve
          flash[:alert] = "Application approved."
        end
      else
        flash[:alert] = "Submission Unsuccessful."
      end
    else
      flash[:notice] = "Updating application failed."
    end
    respond_with(:customer, @application)
  end
  
  # DELETE /store/applications/1
  #-------------------------------------------------------------------
  def destroy
    @application = Application.find(params[:id])
    @application.destroy
    flash[:notice] = "Successfully destroyed application."
    respond_with(:customer, @application)
  end

  private
  def update_application_params
    params.require(:application).permit( 
      :time_at_address, :rent_or_own, :rent_payment )
  end
end