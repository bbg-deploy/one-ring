# Credda
# Copyright (C) 2012-2012 by Bryce Senz
#------------------------------------------------------------------------------ 
class ApplicationController < ActionController::Base
  before_filter :check_mobile
  check_authorization :unless => :devise_controller?
  
  # Defines how the application will respond to different format requests
  # TODO: Validate that all permissions are acceptable and confirm this logic
  #----------------------------------------------------------------------------
  respond_to :html
#  respond_to :js
#  respond_to :json, :xml, :except => [:edit, :update]
#  respond_to :atom, :csv, :rss, :only => :index

  rescue_from ActiveRecord::RecordNotFound, :with => :respond_to_not_found
  rescue_from CanCan::AccessDenied, :with => :respond_to_access_denied
  
  # SECURITY - Protect Form IDs from forgery
  #----------------------------------------------------------------------------
  protect_from_forgery
 
 # Helpers
  helper_method :current_user
  
  def current_user
    begin
      return current_customer unless current_customer.nil?
      return current_store unless current_store.nil?
      return current_employee unless current_employee.nil?
    rescue
      return nil
    end
  end

  private
  def current_ability
    Ability.new(current_user)
  end

  def check_mobile
    return (request.user_agent =~ /Mobile|webOS/)
  end

  #----------------------------------------------------------------------------
  def respond_to_not_found
    flash[:alert] = t(:msg_not_found)

    respond_to do |format|
      format.html { redirect_to user_home_path }
      format.js   { render(:update) { |page| page.reload } }
      format.json { render :text => flash[:alert], :status => :not_found }
      format.xml  { render :text => flash[:alert], :status => :not_found }
    end
  end

  #----------------------------------------------------------------------------
  def respond_to_access_denied
    flash[:alert] = t(:msg_not_authorized)

    respond_to do |format|
      format.html { redirect_to user_home_path }
      format.js   { render(:update) { |page| page.reload } }
      format.json { render :text => flash[:alert], :status => :unauthorized }
      format.xml  { render :text => flash[:alert], :status => :unauthorized }
    end
  end
  
  def user_home_path
    return customer_home_path if current_user.is_a?(Customer)
    return store_home_path if current_user.is_a?(Store)
    return employee_home_path if current_user.is_a?(Employee)
    return home_path
  end
end