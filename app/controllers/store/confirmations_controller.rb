class Store::ConfirmationsController < Devise::ConfirmationsController
  include ActiveModel::ForbiddenAttributesProtection

  # Authentication filters
  prepend_before_filter :require_no_authentication, :only => [ :new, :create, :show ]
  before_filter :check_scope_conflict

  # GET /store/confirmation/new
  def new
    @store = Store.new
  end

  # POST /store/confirmation
  def create
    @store = Store.send_confirmation_instructions(create_store_params)

    if successfully_sent?(@store)
      respond_with({}, :location => home_path)
    else
      respond_with(@store)
    end
  end

  # GET /store/confirmation?confirmation_token=abcdef
  def show
    @store = Store.confirm_by_token(params[:confirmation_token])

    if @store.errors.empty?
      set_flash_message(:notice, :confirmed) if is_navigational_format?
      sign_in(:store, @store)
      redirect_to store_home_path
    else
      respond_with_navigational(@store.errors, :status => :unprocessable_entity){ render :new }
    end
  end

  protected
  def check_scope_conflict
    redirect_to store_scope_conflict_path if (!(current_user.nil?) && (current_store.nil?))
  end

  def after_sign_in_path_for(store)
    store_home_path
  end

  private
  def create_store_params
    params.require(:store).permit(:email)
  end
end