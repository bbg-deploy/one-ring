extend SeedFunctions

after "development:employee_roles" do
  puts "Seeding Employees"
  if (Employee.find_by_username("superadmin").nil?)
    employee = create_employee({:username => "superadmin", :password => "demopass", :password_confirmation => "demopass"})
    unless employee.nil?
      puts "-- created Employee #{employee.username}"
      employee.approve!
      puts "-- approved Employee #{employee.username}"
      employee.confirm!
      puts "-- confirmed #{employee.username}"
    end  
  end
end

