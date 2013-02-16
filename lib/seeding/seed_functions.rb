require 'ffaker'

module SeedFunctions
  # Customers Scope
  #----------------------------------------------------------------------------
  def create_customer(options = {})
    dummy_first_name = Faker::Name.first_name
    dummy_middle_name = Faker::Name.first_name
    dummy_last_name = Faker::Name.last_name
    dummy_username = "#{dummy_first_name}_#{Random.new.rand(1..100)}"
    dummy_email = "#{dummy_username}@notcredda.com"
    dummy_password = "demopass"
    dummy_social_security_number = "345-89-#{Random.new.rand(1000..9999)}"

    defaults = { :username => dummy_username,
                 :password => dummy_password,
                 :password_confirmation => dummy_password,
                 :email => dummy_email,
                 :email_confirmation => dummy_email,
                 :first_name => dummy_first_name,
                 :middle_name => dummy_middle_name,
                 :last_name => dummy_last_name,
                 :social_security_number => dummy_social_security_number,
                 :date_of_birth => 28.years.ago,
                 :mailing_address_attributes => { 
                   :street => Faker::AddressUS.street_address,
                   :city => Faker::AddressUS.city,
                   :state => Faker::AddressUS.state,
                   :zip_code => Faker::AddressUS.zip_code,
                   :country => "United States" },
                 :phone_number_attributes => { 
                   :phone_number_type => "customer",
                   :phone_number => Faker::PhoneNumber.short_phone_number,
                   :cell_phone => "0",
                   :primary => "1" },
                 :terms_agreement => "1" }
                   
    options = defaults.merge(options)
    customer = Customer.new(options)
    puts "Customer = #{customer.inspect}"
    puts "Valid? = #{customer.valid?}"
    begin
      customer.save!
    rescue StandardError => e
      puts "Customer #{options[:first_name]} #{options[:last_name]} (user #{options[:username]}) not saved"
      puts e.message
    else
      return customer
    end
  end

  def create_payment_profile(options = {})
    dummy_customer = Customer.offset(rand(Customer.count)).first
    #Account Holder Details
    dummy_first_name = dummy_customer.first_name
    dummy_last_name = dummy_customer.last_name

    #Dummy Billing Address
    dummy_street   = dummy_customer.mailing_address.street
    dummy_city     = dummy_customer.mailing_address.city
    dummy_state    = dummy_customer.mailing_address.state
    dummy_zip_code = dummy_customer.mailing_address.zip_code
    dummy_country  = dummy_customer.mailing_address.country
    
    #Dummy Credit Card Details
    dummy_credit_card_brand = "visa"
    dummy_credit_card_number = "4111111111111111"
    dummy_credit_card_verification = "41#{Random.new.rand(0..9)}"
    dummy_credit_card_expiration_date = 2.years.from_now
    dummy_credit_card_expiration_month = "#{Random.new.rand(1..12)}"
    dummy_credit_card_expiration_year = "#{Random.new.rand((Time.now.year + 1)..(Time.now.year + 5))}"

    #Dummy Bank Account Details
    dummy_bank_account_holder = "personal"
    dummy_bank_account_type = "checking"
    dummy_bank_account_number = "100321#{Random.new.rand(100..999)}"
    dummy_bank_routing_number = "111000025"
    
    if (options[:payment_type] == "credit_card")
      defaults = {
        :customer                       => dummy_customer,
        :payment_type                   => "credit_card",
        :first_name                     => dummy_first_name,
        :last_name                      => dummy_last_name,
        :billing_address_attributes => {
          :address_type                 => 'billing',
          :street                       => dummy_street,
          :city                         => dummy_city,
          :state                        => dummy_state,
          :zip_code                     => dummy_zip_code,
          :country                      => dummy_country
        },
        :credit_card_attributes => {
          :brand                        => dummy_credit_card_brand,
          :credit_card_number           => dummy_credit_card_number,
          :expiration_date              => dummy_credit_card_expiration_date,
          :ccv_number                   => dummy_credit_card_verification
        }
      }
    else
      defaults = {
        :customer                       => dummy_customer,
        :payment_type                   => "bank_account",
        :first_name                     => dummy_first_name,
        :last_name                      => dummy_last_name,
        :billing_address_attributes => {
          :address_type                 => 'billing',
          :street                       => dummy_street,
          :city                         => dummy_city,
          :state                        => dummy_state,
          :zip_code                     => dummy_zip_code,
          :country                      => dummy_country
        },
        :bank_account_attributes => {
          :account_holder               => dummy_bank_account_holder,
          :account_type                 => dummy_bank_account_type,
          :routing_number               => dummy_bank_routing_number,
          :account_number               => dummy_bank_account_number
        }
      }
    end
    
    
    options = defaults.merge(options)
    payment_profile = PaymentProfile.new(options)
    begin
      payment_profile.save!
    rescue StandardError => e
      puts "Payment Profile not saved"
      puts "Error = #{e.inspect}"
      puts e.message
    else
      return payment_profile
    end
  end

  # Stores Scope
  #----------------------------------------------------------------------------
  def create_employee(options = {})
    dummy_first_name = Faker::Name.first_name
    dummy_middle_name = Faker::Name.first_name
    dummy_last_name = Faker::Name.last_name
    dummy_username = "#{Faker::Name.first_name}_#{Random.new.rand(1..100)}"
    dummy_email = "#{Faker::Name.first_name}@credda.com"
    dummy_password = "demopass"
    dummy_social_security_number = "345-89-#{Random.new.rand(1000..9999)}"

    defaults = { :username => dummy_username,
                 :password => dummy_password,
                 :password_confirmation => dummy_password,
                 :email => dummy_email,
                 :email_confirmation => dummy_email,
                 :first_name => dummy_first_name,
                 :middle_name => dummy_middle_name,
                 :last_name => dummy_last_name,
                 :date_of_birth => 28.years.ago,
                 :terms_agreement => "1" }
                   
    options = defaults.merge(options)
    employee = Employee.create(options)
    begin
      employee.save!
    rescue StandardError => e
      puts "Employee #{options[:username]} not saved"
      puts e.message
    else
      return employee
    end
  end

  def create_employee_role(options = {})
    dummy_name = Faker::Name.first_name

    defaults = { :name => dummy_name }
                   
    options = defaults.merge(options)
    employee_role = EmployeeRole.create(options)
    begin
      employee_role.save!
    rescue StandardError => e
      puts "EmployeeRole #{options[:name]} not saved"
      puts e.message
    else
      return employee_role
    end
  end

  # Employee Scope
  #----------------------------------------------------------------------------
  def create_store(options = {})
    dummy_name = "#{Faker::Company.name}"
    dummy_username = "#{Faker::Name.first_name}_#{Random.new.rand(1..100)}"
    dummy_email = "#{dummy_username}@notcredda.com"
    dummy_password = "demopass"
    dummy_employer_identification_number = "34-589#{Random.new.rand(1000..9999)}"

    defaults = { :username => dummy_username,
                 :password => dummy_password,
                 :password_confirmation => dummy_password,
                 :email => dummy_email,
                 :email_confirmation => dummy_email,
                 :name => dummy_name,
                 :employer_identification_number => dummy_employer_identification_number,
                 :addresses_attributes => { "0" => {
                   :address_type => "store",
                   :street => Faker::AddressUS.street_address,
                   :city => Faker::AddressUS.city,
                   :state => Faker::AddressUS.state,
                   :zip_code => Faker::AddressUS.zip_code,
                   :country => "United States" } },
                 :phone_numbers_attributes => { "0" => { 
                   :phone_number_type => "store",
                   :phone_number => Faker::PhoneNumber.short_phone_number,
                   :cell_phone => "0",
                   :primary => "1" } },
                 :terms_agreement => "1" }
                   
    options = defaults.merge(options)
    store = Store.create(options)

    begin
      store.save!
    rescue StandardError => e
      puts "Store #{options[:name]} (user #{options[:username]}) not saved"
      puts e.message
    else
      return store
    end
  end
end