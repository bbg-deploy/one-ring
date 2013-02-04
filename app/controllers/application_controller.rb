# Credda
# Copyright (C) 2012-2012 by Bryce Senz
#------------------------------------------------------------------------------ 
class ApplicationController < ActionController::Base
#TODO: Force SSL for all of our controllers in the future
#  force_ssl
#  skip_authorization_check
  
  before_filter :check_mobile
  before_filter :current_user

  # Defines how the application will respond to different format requests
  # TODO: Validate that all permissions are acceptable and confirm this logic
  #----------------------------------------------------------------------------
  respond_to :html
  respond_to :js
  respond_to :json, :xml, :except => [:edit, :update]
  respond_to :atom, :csv, :rss, :only => :index

  rescue_from ActiveRecord::RecordNotFound, :with => :respond_to_not_found
#  rescue_from CanCan::AccessDenied,         :with => :respond_to_access_denied
  
  # SECURITY - Protect Form IDs from forgery
  #----------------------------------------------------------------------------
  protect_from_forgery

  # SECURITY - Require all controllers to check authorization (except devise)
  #----------------------------------------------------------------------------
#  check_authorization :unless => :devise_controller?

  def current_user
    @current_user = nil
  end

  def current_ability
    @current_ability ||= AnonymousAbility.new
  end

  def check_mobile
    if (request.user_agent =~ /Mobile|webOS/)
      @mobile_device = true
    else
      @mobile_device = false
    end
  end

  private
  #----------------------------------------------------------------------------
  def respond_to_not_found
    flash[:warning] = t(:msg_not_found)

    respond_to do |format|
      format.html {
        render :template => '/error/404', :status => 404
      }
      format.js   { render(:update) { |page| page.reload } }
      format.json { render :text => flash[:warning], :status => :not_found }
      format.xml  { render :text => flash[:warning], :status => :not_found }
    end
  end

  #----------------------------------------------------------------------------
  def respond_to_access_denied
    flash[:warning] = t(:msg_not_authorized)

    respond_to do |format|
      format.html {
        render :template => '/error/403', :status => 403
      }
      format.js   { render(:update) { |page| page.reload } }
      format.json { render :text => flash[:warning], :status => :unauthorized }
      format.xml  { render :text => flash[:warning], :status => :unauthorized }
    end
  end
end