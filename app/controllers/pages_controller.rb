class PagesController < ApplicationController
  skip_authorization_check

  def home
    @customers = Customer.all
    
    respond_to do |format|
      format.json { }   
      format.xml  { }
      format.html  # this renders home.html.erb
    end 
  end  
end
