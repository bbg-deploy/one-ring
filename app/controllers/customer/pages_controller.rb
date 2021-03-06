class Customer::PagesController < Customer::BaseController
#  before_filter :authenticate_customer!
  skip_authorization_check

  def home
    @matching_applications = current_customer.possible_unclaimed_applications
    @contract_details = [
      { :name => "Contract 1",
        :description => "Contract for some Tires",
        :total => BigDecimal.new("1600"),
        :paid_off => BigDecimal.new("600") },
      { :name => "Contract 2",
        :description => "Contract for some Watches",
        :total => BigDecimal.new("2200"),
        :paid_off => BigDecimal.new("1900") }
    ]
    
    respond_to do |format|
      format.json { }   
      format.xml  { }
      format.html  # this renders home.html.erb
    end 
  end  

  private
end
