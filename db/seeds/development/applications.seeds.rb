extend SeedFunctions

after "development:stores", "development:customers" do
  puts "Seeding Unclaimed Applications"
  unless (Store.find_by_username("store").nil?) || (Customer.find_by_username("customer").nil?)
    2.times do
      store = Store.find_by_username("store")
      customer = Customer.find_by_username("customer")
      application = create_application(:store_account_number => store.account_number, :matching_email => customer.email)
      puts "-- created Application #{application.name}"
    end
  end

  puts "Seeding Claimed Applications"
  unless (Store.find_by_username("store").nil?) || (Customer.find_by_username("customer").nil?)
    store = Store.find_by_username("store")
    customer = Customer.find_by_username("customer")
    application = create_application(:store_account_number => store.account_number, :customer_account_number => customer.account_number)
    puts "-- created Application #{application.name}"
    application.claim!
    puts "-- claimed Application"
  end
end
