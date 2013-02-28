class PagesController < ApplicationController
  before_filter :require_no_authentication, :only => [:home]
  skip_authorization_check

  def home
    @customers = Customer.all
    
    respond_to do |format|
      format.json { }   
      format.xml  { }
      format.html  # this renders home.html.haml
    end 
  end  

  def learn_more
    respond_to do |format|
      format.json { }   
      format.xml  { }
      format.html  # this renders learn_more.html.haml
    end 
  end  

  def for_business
    respond_to do |format|
      format.json { }   
      format.xml  { }
      format.html  # this renders for_business.html.haml
    end 
  end
  
  def security
    respond_to do |format|
      format.json { }   
      format.xml  { }
      format.html  # this renders for_business.html.haml
    end 
  end

  def privacy
    respond_to do |format|
      format.json { }   
      format.xml  { }
      format.html  # this renders for_business.html.haml
      format.pdf do
        pdf = PrivacyPdf.new
        send_data pdf.render, filename: "CreddaPrivacy.pdf", type: "application/pdf", disposition: "inline"
      end
    end 
  end
  
      
      
      
  private
  def require_no_authentication
    unless current_user.nil?
      redirect_to customer_home_path unless current_customer.nil?
      redirect_to store_home_path    unless current_store.nil?
      redirect_to employee_home_path unless current_employee.nil?
    end
  end
end
