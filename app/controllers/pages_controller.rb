class PagesController < ApplicationController
  load_and_authorize_resource
  
  def home
    respond_to do |format|
      format.json { }   
      format.xml  { }
      format.html  # this renders home.html.erb
    end 
  end  
end
