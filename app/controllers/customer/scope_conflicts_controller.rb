class Customer::ScopeConflictsController < Customer::ApplicationController
#  include ActiveModel::ForbiddenAttributesProtection
  skip_authorize_resource

  # GET /customer/scope_conflict
  #-----------------------------------------------------------------------
  def scope_conflict
    
  end

  # POST /customer/resolve_conflict
  #-----------------------------------------------------------------------
  def resolve_conflict
    # if yes, logout all scopes and redirect to new_customer_session_path
    # else, redirect to home_path
  end

  private
  def resolve_conflict_params
  end
end