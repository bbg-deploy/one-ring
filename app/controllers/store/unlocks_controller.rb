class Store::UnlocksController < Devise::UnlocksController
  include ActiveModel::ForbiddenAttributesProtection

  prepend_before_filter :require_no_authentication

  # GET /store/unlock/new
  def new
    @store = Store.new
  end

  # POST /store/unlock
  def create
    @store = Store.send_unlock_instructions(create_customer_params)

    if successfully_sent?(@store)
      respond_with({}, :location => new_store_session_path)
    else
      respond_with(@store)
    end
  end

  # GET /store/unlock?unlock_token=abcdef
  def show
    @store = Store.unlock_access_by_token(params[:unlock_token])

    if @store.errors.empty?
      set_flash_message :notice, :unlocked
      respond_with_navigational(@store){ redirect_to new_store_session_path }
    else
      respond_with_navigational(@store.errors, :status => :unprocessable_entity){ render :new }
    end
  end

  protected
  def after_sign_in_path_for(store)
    store_home_path
  end

  private
  def create_store_params
    params.require(:store).permit(:email)
  end
end