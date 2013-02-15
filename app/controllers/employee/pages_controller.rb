class Employee::PagesController < Employee::ApplicationController
  skip_authorization_check

  def home
    @clients = Client.all
    
    respond_to do |format|
      format.json { }   
      format.xml  { }
      format.html  # this renders home.html.erb
    end 
  end  
end
