class PagesController < ApplicationController

  def home
    if !current_admin.nil?
      redirect_to [:admin, :home]
    elsif !current_analyst.nil?
      redirect_to [:analyst, :home]
    elsif !current_agent.nil?
      redirect_to [:agent, :home]
    elsif !current_store.nil? 
      redirect_to [:store, :home]
    elsif !current_customer.nil? 
      redirect_to [:customer, :home]
    else
      respond_to do |format|
        format.json { }   
        format.xml  { }
        format.html  # this renders home.html.erb
      end
    end 
  end
  
  def about
    respond_to do |format|
      format.json { }   
      format.xml  { }
      format.html # this renders about.html.haml
    end 
  end

  def learn_more
    respond_to do |format|
      format.json { }   
      format.xml  { }
      format.html # this renders learn_more.html.haml
    end 
  end

  def for_business
    respond_to do |format|
      format.json { }   
      format.xml  { }
      format.html # this renders for_business.html.haml
    end 
  end
end
