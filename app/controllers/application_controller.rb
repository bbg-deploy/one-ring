# Credda
# Copyright (C) 2012-2012 by Bryce Senz
#------------------------------------------------------------------------------ 
class ApplicationController < ActionController::Base
#TODO: Force SSL for all of our controllers in the future
#  force_ssl  
  before_filter :check_mobile

  # Defines how the application will respond to different format requests
  # TODO: Validate that all permissions are acceptable and confirm this logic
  #----------------------------------------------------------------------------
  respond_to :html
  respond_to :js
  respond_to :json, :xml, :except => [:edit, :update]
  respond_to :atom, :csv, :rss, :only => :index

  rescue_from ActiveRecord::RecordNotFound, :with => :respond_to_not_found
  
  # SECURITY - Protect Form IDs from forgery
  #----------------------------------------------------------------------------
  protect_from_forgery
 
 # Helpers
  helper_method :current_user
 
  private
  def current_user
#    flash[:notice] = "SESSION = #{session.inspect}"
    return current_customer unless current_customer.nil?
    return current_store unless current_store.nil?
    return nil
  end

  def check_mobile
    return (request.user_agent =~ /Mobile|webOS/)
  end

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

  def authority_forbidden(error)
    Authority.logger.warn(error.message)
    redirect_to request.referrer.presence || root_path, :alert => 'You are not authorized to complete that action.'
  end
end