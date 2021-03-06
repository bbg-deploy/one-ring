class Store::BaseController < ::ApplicationController
  layout 'store_layout'

  before_filter :authenticate_store!
  before_filter :get_store

  def current_user
    @current_user = current_store unless current_store.nil?
  end
  
  def get_store
    @current_store = current_store
  end  
  private
end