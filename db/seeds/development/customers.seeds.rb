extend SeedFunctions

puts "Seeding Customers"
# Demo Customer
#------------------------------------------------------------------------------
if (Customer.find_by_username("customer").nil?)
  # Creation
  customer = create_customer({:username => "customer", :password => "demopass", :password_confirmation => "demopass"})
  unless customer.nil?
    puts "-- created Customer #{customer.username}"
    customer.confirm!
    puts "-- confirmed #{customer.username}"
    if customer.cim_customer_profile_id.nil?
      puts "-- CIMCustomerProfileID is nil"
    end
  end

  #Payment Profiles
  payment_profile = create_payment_profile({:customer => customer, :payment_type => "credit_card"})
  unless payment_profile.nil?
    puts "-- created Payment Profile for #{customer.username}"
  end
end

# Dummy Customers
#------------------------------------------------------------------------------
if (Customer.count < 3)
  3.times do
#    customer = create_customer  
#    unless customer.nil?
#      puts "-- created Customer #{customer.username}"
#      customer.confirm!
#      puts "-- confirmed #{customer.username}"
#    end
  end  
end
