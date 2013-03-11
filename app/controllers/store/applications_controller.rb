class Store::ApplicationsController < Employee::ApplicationController
  include ActiveModel::ForbiddenAttributesProtection
  load_and_authorize_resource

  # GET /store/applications
  #-----------------------------------------------------------------------
  def index
    @applications = Applications.all
    respond_with(:store, @applications)
  end

  # GET /store/applications/1
  #-------------------------------------------------------------------
  def show
    @applications = Application.find(params[:id])
    respond_with(:store, @applications)
  end
  
  # GET /store/applications/new
  #-------------------------------------------------------------------
  def new
    @application = Application.new
    respond_with(:store, @application)
  end

  # POST /store/applications
  #-------------------------------------------------------------------
  def create
    @application = Application.new(create_application_params)
    if @application.save
      flash[:notice] = "Successfully started application."
    else
      flash[:alert] = YAML.load_file("#{Rails.root}/config/locales/devise.en.yml")['en']['devise']['failure']['invalid_data']
    end
    respond_with(:store, @application)
  end

  # GET /store/applications/1/edit
  #-------------------------------------------------------------------
  def edit
    @application = Application.find(params[:id])
    respond_with(:store, @application)
  end

  # PUT /employee/applications/1
  #-----------------------------------------------------------------
  def update
    @application = Application.find(params[:id])

    if @application.update_attributes(update_store_params)
      flash[:notice] = "Successfully updated application."
    else
      flash[:notice] = "Updating application failed."
    end
    respond_with(:store, @application)
  end
  
  # DELETE /store/applications/1
  #-------------------------------------------------------------------
  def destroy
    @application = Application.find(params[:id])
    @application.destroy!
    flash[:notice] = "Successfully destroyed application."
    respond_with(:store, @application)
  end

  # PUT /employee/stores/1/approve
  #-------------------------------------------------------------------
#  def approve
#    @store = Store.find(params[:id])
#    @store.approve_account!
#    StoreAuthenticationMailer.confirmation_instructions(@store).deliver
#    flash[:notice] = "Successfully approved store."
#    respond_with(:employee, @store)
#  end

  private
  def create_application_params
    params.require(:application).permit(
      :username, :password, :password_confirmation, :email, :email_confirmation, 
      :name, :employer_identification_number, 
      {:addresses_attributes  => [:street, :city, :state, :zip_code, :country]}, 
      {:phone_numbers_attributes => [:phone_number_type, :phone_number, :cell_phone]}, :terms_agreement )
  end

  def update_application_params
    params.require(:application).permit(
      :username, :password, :password_confirmation, :email, :email_confirmation, 
      :name, :employer_identification_number, 
      {:addresses_attributes  => [:street, :city, :state, :zip_code, :country]}, 
      {:phone_numbers_attributes => [:phone_number_type, :phone_number, :cell_phone]} )
  end
end