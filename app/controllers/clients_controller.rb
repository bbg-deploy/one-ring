class ClientsController < ApplicationController
  include ActiveModel::ForbiddenAttributesProtection
  prepend_before_filter :require_administrator!
  load_and_authorize_resource

  # GET /clients
  #-----------------------------------------------------------------------
  def index
    @clients = Client.all
    respond_with(:employee, @clients)
  end

  # GET /clients/1
  #-------------------------------------------------------------------
  def show
    @client = Client.find(params[:id])
    respond_with(:employee, @client)
  end
  
  # GET /clients/new
  #-------------------------------------------------------------------
  def new
    @client = Client.new
    respond_with(:employee, @client)
  end

  # POST /clients
  #-------------------------------------------------------------------
  def create
    @client = Client.new(create_client_params)
    if @client.save
      flash[:notice] = "Successfully created client."  
    end
    respond_with(:employee, @client)
  end

  # GET /clients/1/edit
  #-------------------------------------------------------------------
  def edit
    @client = Client.find(params[:id])
    respond_with(:employee, @client)
  end

  # PUT /clients/1
  #-----------------------------------------------------------------
  def update
    @client = Client.find(params[:id])
    if @client.update_attributes(update_client_params)
      flash[:notice] = "Successfully updated client."
    else
      flash[:notice] = "Updating client."
    end
    respond_with(:employee, @client)
  end
  
  # DELETE /customer/clients/1
  #-------------------------------------------------------------------
  def destroy
    @client = Client.find(params[:id])
    @client.destroy
    flash[:notice] = "Successfully deleted client."  
    respond_with(:employee, @client)
  end

  private
  def create_client_params
    params.require(:client).permit(:name, :app_id, :app_id_confirmation)
  end

  def update_client_params
    params.require(:client).permit(:name, :app_id, :app_id_confirmation)
  end
end