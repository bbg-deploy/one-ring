class Store::PagesController < Store::ApplicationController
  skip_authorization_check

  def home
    respond_to do |format|
      format.json { }   
      format.xml  { }
      format.html  # this renders home.html.erb
    end 
  end  
end
