require 'ffaker'

module SeedFunctions
  def create_admin(options = {})
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
    admin = Admin.create(options)
    begin
      admin.save!
    rescue StandardError => e
      puts "Admin #{options[:username]} not saved"
      puts e.message
    else
      return admin
    end
  end

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
    customer = Customer.create(options)
    begin
      customer.save!
    rescue StandardError => e
      puts "Customer #{options[:first_name]} #{options[:last_name]} (user #{options[:username]}) not saved"
      puts e.message
    else
      return customer
    end
  end

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

  def create_product_category(options = {})
    dummy_name = Faker::Lorem.words

    defaults = { :name => dummy_name }
                   
    options = defaults.merge(options)
    product_category = ProductCategory.create(options)

    begin
      product_category.save!
    rescue StandardError => e
      puts "Product Category #{options[:name]} not saved"
      puts e.message
    else
      return product_category
    end
  end

  def create_lease(options = {}, state = "unclaimed")
    dummy_customer = Customer.offset(rand(Customer.count)).first
    dummy_store = Store.offset(rand(Store.count)).first
    
    dummy_products = Hash.new()
    number_of_products = Random.new.rand(1..4)

    number_of_products.times do |i|
      dummy_products[i] = {
          :product_categories => [ProductCategory.offset(rand(ProductCategory.count)).first],
          :name => Faker::Lorem.word,
          :price => Random.new.rand(19.99..199.00),
          :description => Faker::Lorem.paragraph
      }
    end
    
    defaults = { 
      :customer => dummy_customer,
      :store => dummy_store,
      :products_attributes => dummy_products,
      :payment_frequency => "weekly",
      :lease_choice => 1,
      :id_verified => 1
    }
    
    options = defaults.merge(options)
    lease = Lease.create(options)

    begin
      if state == "unclaimed"
      elsif state == "claimed"
        lease.claim
        unless (lease.claimed?)
          puts "--- Lease claim failed."
        end
      elsif state == "submitted"
        lease.claim
        lease.submit
        unless (lease.approved?) || (lease.denied?)
          puts "--- Lease submit failed."
        end
      elsif state == "finalized"
        lease.claim
        lease.submit
        lease.finalize
        unless (lease.finalized?)
          puts "--- Lease finalize failed."
        end
      elsif state == "verified"
        lease.claim
        lease.submit
        lease.finalize
        lease.verify
        unless (lease.verified?)
          puts "--- Lease verify failed."
        end
      elsif state == "active"
        lease.claim
        lease.submit
        lease.finalize
        lease.verify
        lease.activate
        unless (lease.active?)
          puts "--- Lease verify failed."
        end
      else
      end
      lease.save!
    rescue StandardError => e
      puts "Lease not saved"
      puts e.message
    else
      return lease
    end
  end

  def create_payment_profile(options = {})
    dummy_customer = Customer.offset(rand(Customer.count)).first
    #Account Holder Details
    dummy_first_name = dummy_customer.first_name
    dummy_last_name = dummy_customer.last_name
    #Dummy Credit Card Details
    dummy_credit_card_brand = "visa"
    dummy_credit_card_number = "411122223333#{Random.new.rand(1000..9999)}"
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
        :credit_card_attributes => {
          :first_name                   => dummy_first_name,
          :last_name                    => dummy_last_name,
          :brand                        => dummy_credit_card_brand,
          :credit_card_number           => dummy_credit_card_number,
          :expiration_date              => dummy_credit_card_expiration_date,
          :ccv_number                   => dummy_credit_card_verification
        }
      }
    else
      defaults = {
        :customer                       => dummy_customer,
        :payment_type                   => "credit_card",
        :first_name                     => dummy_first_name,
        :last_name                      => dummy_last_name,
        :bank_account_attributes => {
          :first_name                   => dummy_first_name,
          :last_name                    => dummy_last_name,
          :account_holder               => dummy_bank_account_holder,
          :account_type                 => dummy_bank_account_type,
          :routing_number               => dummy_bank_routing_number,
          :account_number               => dummy_bank_account_number
        }
      }
    end

    
    options = defaults.merge(options)
    payment_profile = PaymentProfile.create(options)

    begin
      payment_profile.save!
    rescue StandardError => e
      puts "Payment Profile not saved"
      puts e.message
    else
      return payment_profile
    end
  end
end