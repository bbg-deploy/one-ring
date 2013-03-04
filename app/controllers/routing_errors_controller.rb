class RoutingErrorsController < ApplicationController
  skip_authorization_check

  def not_found
    respond_to do |format|
      format.json { }   
      format.xml  { }
      format.html  # this renders not_found.html.slim
    end 
  end  
end
