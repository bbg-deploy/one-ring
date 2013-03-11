class Employee::LedgersController < Employee::ApplicationController
  include ActiveModel::ForbiddenAttributesProtection

  # GET /ledgers
  #-----------------------------------------------------------------------
  def index
    @ledgers = Ledger.all
    respond_with(@ledgers)
  end

  # GET /ledgers/1
  #-------------------------------------------------------------------
  def show
    @ledger = Ledger.find(params[:id])
    respond_with(@ledger)
  end
  
  # GET /ledgers/new
  #-------------------------------------------------------------------
  def new
    @ledger = Ledger.new
    respond_with(@ledger)
  end

  # POST /ledgers
  #-------------------------------------------------------------------
  def create
    @ledger = Ledger.new(create_ledger_params)
    if @ledger.save
      flash[:notice] = "Successfully created ledger."  
    end
    respond_with(@ledger)
  end

  # GET /ledgers/1/edit
  #-------------------------------------------------------------------
  def edit
    @ledger = Ledger.find(params[:id])
    respond_with(@ledger)
  end

  # PUT /ledgers/1
  #-----------------------------------------------------------------
  def update
    @ledger = Ledger.find(params[:id])
    if @ledger.update_attributes(update_ledger_params)
      flash[:notice] = "Successfully updated ledger."
    end
    respond_with(@ledger)
  end
  
  # DELETE /ledgers/1
  #-------------------------------------------------------------------
  def destroy
    @ledger = Ledger.find(params[:id])
    @ledger.destroy
    flash[:notice] = "Successfully deleted ledger."  
    respond_with(@ledger)
  end

  private
  def create_ledger_params
    params.require(:ledger).permit(:contract, :contract_type)
  end

  def update_ledger_params
    params.require(:ledger).permit(:contract, :contract_type)
  end
end