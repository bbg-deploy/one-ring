class Store::ApplicationsController < Store::BaseController
  include ActiveModel::ForbiddenAttributesProtection
  load_and_authorize_resource

  # GET /store/applications
  #-----------------------------------------------------------------------
  def index
    @applications = Application.all
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
    @product_types = Product.descendants.map{|klass| klass.name}
    @application = Application.new
    1.times do
      @application.products.build
    end
    respond_with(:store, @application)
  end

  # POST /store/applications
  #-------------------------------------------------------------------
  def create
    @application = Application.new(create_application_params)
    @application.store_account_number = current_store.account_number
    
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
    @product_types = Product.descendants.map{|klass| klass.name}
    @application = Application.find(params[:id])
    respond_with(:store, @application)
  end

  # PUT /employee/applications/1
  #-----------------------------------------------------------------
  def update
    @application = Application.find(params[:id])

    if @application.update_attributes(update_application_params)
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
    @application.destroy
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
      :matching_email,
      {:products_attributes  => [:type, :name, :price, :id_number, :description]} )
  end

  def update_application_params
    params.require(:application).permit( 
      :matching_email,
      {:products_attributes  => [:type, :name, :price, :id_number, :description]} )
  end
end