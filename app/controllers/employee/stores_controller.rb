class Employee::StoresController < Employee::BaseController
  include ActiveModel::ForbiddenAttributesProtection
  load_and_authorize_resource

  # GET /employee/stores
  #-----------------------------------------------------------------------
  def index
    @stores = Store.all
    respond_with(:employee, @stores)
  end

  # GET /employee/stores/1
  #-------------------------------------------------------------------
  def show
    @store = Store.find(params[:id])
    respond_with(:employee, @store)
  end
  
  # GET /employee/stores/new
  #-------------------------------------------------------------------
  def new
    @store = Store.new
    1.times { @store.addresses.build }
    1.times { @store.phone_numbers.build }
    respond_with(:employee, @store)
  end

  # POST /employee/stores
  #-------------------------------------------------------------------
  def create
    @store = Store.new(create_store_params)
    if @store.save
      flash[:notice] = "Successfully created store."  
    else
      flash[:alert] = YAML.load_file("#{Rails.root}/config/locales/devise.en.yml")['en']['devise']['failure']['invalid_data']
    end
    respond_with(:employee, @store)
  end

  # GET /employee/stores/1/edit
  #-------------------------------------------------------------------
  def edit
    @store = Store.find(params[:id])
    respond_with(:employee, @store)
  end

  # PUT /employee/stores/1
  #-----------------------------------------------------------------
  def update
    @store = Store.find(params[:id])

    if @store.update_attributes(update_store_params)
      flash[:notice] = "Successfully updated store."
    else
      flash[:notice] = "Updating store failed."
    end
    respond_with(:employee, @store)
  end
  
  # DELETE /employee/stores/1
  #-------------------------------------------------------------------
  def destroy
    @store = Store.find(params[:id])
    @store.cancel_account!
    flash[:notice] = "Successfully cancelled store."  
    respond_with @store, :location => employee_stores_path
  end

  # PUT /employee/stores/1/approve
  #-------------------------------------------------------------------
  def approve
    @store = Store.find(params[:id])
    @store.approve_account!
    StoreAuthenticationMailer.confirmation_instructions(@store).deliver
    flash[:notice] = "Successfully approved store."
    respond_with(:employee, @store)
  end

  private
  def create_store_params
    params.require(:store).permit(
      :username, :password, :password_confirmation, :email, :email_confirmation, 
      :name, :employer_identification_number, 
      {:addresses_attributes  => [:street, :city, :state, :zip_code, :country]}, 
      {:phone_numbers_attributes => [:phone_number_type, :phone_number, :cell_phone]}, :terms_agreement )
  end

  def update_store_params
    if (params[:store][:password].blank?) && (params[:store][:password_confirmation].blank?)
       params[:store].delete :password
       params[:store].delete :password_confirmation
    end

    params.require(:store).permit(
      :username, :password, :password_confirmation, :email, :email_confirmation, 
      :name, :employer_identification_number, 
      {:addresses_attributes  => [:street, :city, :state, :zip_code, :country]}, 
      {:phone_numbers_attributes => [:phone_number_type, :phone_number, :cell_phone]} )
  end
end