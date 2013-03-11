class Employee::ContractsController < Employee::ApplicationController
  include ActiveModel::ForbiddenAttributesProtection

  # GET /contracts
  #-----------------------------------------------------------------------
  def index
    @contracts = Contract.all
    respond_with(@contracts)
  end

  # GET /contracts/1
  #-------------------------------------------------------------------
  def show
    @contract = Contract.find(params[:id])
    respond_with(@contract)
  end
  
  # GET /contracts/new
  #-------------------------------------------------------------------
  def new
    @contract = Contract.new
    respond_with(@contract)
  end

  # POST /contracts
  #-------------------------------------------------------------------
  def create
    @contract = Contract.new(create_contract_params)
    if @contract.save
      flash[:notice] = "Successfully created contract."  
    end
    respond_with(@contract)
  end

  # GET /contracts/1/edit
  #-------------------------------------------------------------------
  def edit
    @contract = Contract.find(params[:id])
    respond_with(@contract)
  end

  # PUT /contracts/1
  #-----------------------------------------------------------------
  def update
    @contract = Contract.find(params[:id])
    if @contract.update_attributes(update_contract_params)
      flash[:notice] = "Successfully updated contract."
    end
    respond_with(@contract)
  end
  
  # DELETE /contracts/1
  #-------------------------------------------------------------------
  def destroy
    @contract = Contract.find(params[:id])
    @contract.destroy
    flash[:notice] = "Successfully deleted contract."  
    respond_with(@contract)
  end

  private
  def create_contract_params
    params.require(:contract).permit(:customer_account_number, :application_number, :type)
  end

  def update_contract_params
    params.require(:contract).permit(:customer_account_number, :application_number, :type)
  end
end