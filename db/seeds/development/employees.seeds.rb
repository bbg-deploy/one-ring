extend SeedFunctions

puts "Seeding Admins"
if (Admin.find_by_username("superadmin").nil?)
  admin = create_admin({:username => "superadmin", :password => "demopass", :password_confirmation => "demopass"})
  unless admin.nil?
    puts "-- created Admin #{admin.username}"
    admin.confirm!
    puts "-- confirmed #{admin.username}"
  end  
end
