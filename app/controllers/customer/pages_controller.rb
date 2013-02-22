class Customer::PagesController < Customer::ApplicationController
  before_filter :authenticate_customer!
  skip_authorization_check

  def home
    respond_to do |format|
      format.json { }   
      format.xml  { }
      format.html  # this renders home.html.erb
    end 
  end  
end
