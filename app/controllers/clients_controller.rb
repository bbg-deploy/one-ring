class ClientsController < ApplicationController
  load_and_authorize_resource

  # GET /clients
  #-----------------------------------------------------------------------
  def index
    @clients = Client.all
    respond_with(@clients)
  end

  # GET /clients/1
  #-------------------------------------------------------------------
  def show
    @client = Client.find(params[:id])
    respond_with(@client)
  end
  
  # GET /client/new
  #-------------------------------------------------------------------
  def new
    @client = PaymentProfile.new
    respond_with(@client)
  end

  # POST /clients
  #-------------------------------------------------------------------
  def create
    @client = Client.new(params[:client])
    if @client.save
      flash[:notice] = "Successfully created client."  
    end
    respond_with(@client)
  end

  # GET /clients/1/edit
  #-------------------------------------------------------------------
  def edit
    @client = Client.find(params[:id])
    respond_with(@client)
  end

  # PUT /clients/1
  #-----------------------------------------------------------------
  def update
    @client = Client.find(params[:id])
    if @client.update_attributes(params[:client])
      flash[:notice] = "Successfully updated client."
    else
      flash[:notice] = "Updating client."
    end
    respond_with(@client)
  end
  
  # DELETE /customer/clients/1
  #-------------------------------------------------------------------
  def destroy
    @client = Client.find(params[:id])
    @client.destroy
    flash[:notice] = "Successfully deleted client."  
    respond_with(@client)
  end
end