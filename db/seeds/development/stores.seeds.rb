extend SeedFunctions

puts "Seeding Stores"
if (Store.find_by_username("store").nil?)
  store = create_store({:username => "store", :password => "demopass", :password_confirmation => "demopass"})
  unless store.nil?
    puts "-- created Store #{store.username}"
    store.confirm!
    puts "-- confirmed #{store.username}"
  end
end

if (Store.count < 2)
  2.times do
    store = create_store
    unless store.nil?
      puts "-- created Store #{store.username}"
      store.confirm!
      puts "-- confirmed #{store.username}"
    end
  end  
end
