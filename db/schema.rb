# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120716021032) do

  create_table "addresses", :force => true do |t|
    t.integer  "addressable_id",                   :null => false
    t.string   "addressable_type",                 :null => false
    t.string   "address_type",     :default => "", :null => false
    t.string   "street",           :default => "", :null => false
    t.string   "city",             :default => "", :null => false
    t.string   "state",            :default => "", :null => false
    t.string   "zip_code",         :default => "", :null => false
    t.string   "country",          :default => "", :null => false
    t.float    "latitude"
    t.float    "longitude"
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
  end

  create_table "customers", :force => true do |t|
    t.string   "username",                :default => "", :null => false
    t.string   "email",                   :default => "", :null => false
    t.string   "encrypted_password",      :default => "", :null => false
    t.string   "first_name",                              :null => false
    t.string   "middle_name"
    t.string   "last_name",                               :null => false
    t.date     "date_of_birth",                           :null => false
    t.string   "social_security_number",                  :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",           :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.integer  "failed_attempts",         :default => 0
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.string   "authentication_token"
    t.string   "cim_customer_profile_id"
    t.datetime "created_at",                              :null => false
    t.datetime "updated_at",                              :null => false
  end

  add_index "customers", ["authentication_token"], :name => "index_customers_on_authentication_token", :unique => true
  add_index "customers", ["cim_customer_profile_id"], :name => "index_customers_on_cim_customer_profile_id", :unique => true
  add_index "customers", ["confirmation_token"], :name => "index_customers_on_confirmation_token", :unique => true
  add_index "customers", ["email"], :name => "index_customers_on_email", :unique => true
  add_index "customers", ["reset_password_token"], :name => "index_customers_on_reset_password_token", :unique => true
  add_index "customers", ["unlock_token"], :name => "index_customers_on_unlock_token", :unique => true
  add_index "customers", ["username"], :name => "index_customers_on_username", :unique => true

  create_table "employees", :force => true do |t|
    t.string   "username",               :default => "", :null => false
    t.string   "email",                  :default => "", :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "first_name",                             :null => false
    t.string   "middle_name"
    t.string   "last_name",                              :null => false
    t.date     "date_of_birth",                          :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.integer  "failed_attempts",        :default => 0
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.string   "authentication_token"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
  end

  add_index "employees", ["authentication_token"], :name => "index_employees_on_authentication_token", :unique => true
  add_index "employees", ["confirmation_token"], :name => "index_employees_on_confirmation_token", :unique => true
  add_index "employees", ["email"], :name => "index_employees_on_email", :unique => true
  add_index "employees", ["reset_password_token"], :name => "index_employees_on_reset_password_token", :unique => true
  add_index "employees", ["unlock_token"], :name => "index_employees_on_unlock_token", :unique => true
  add_index "employees", ["username"], :name => "index_employees_on_username", :unique => true

  create_table "identifications", :force => true do |t|
    t.integer  "customer_id",                           :null => false
    t.string   "identification_type",   :default => "", :null => false
    t.string   "authority",             :default => "", :null => false
    t.string   "identification_number", :default => "", :null => false
    t.datetime "created_at",                            :null => false
    t.datetime "updated_at",                            :null => false
  end

  create_table "payment_profiles", :force => true do |t|
    t.integer  "customer_id",                     :null => false
    t.string   "payment_type",                    :null => false
    t.string   "first_name",                      :null => false
    t.string   "last_name",                       :null => false
    t.string   "last_four_digits",                :null => false
    t.string   "cim_customer_payment_profile_id", :null => false
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
  end

  add_index "payment_profiles", ["cim_customer_payment_profile_id"], :name => "index_payment_profiles_on_cim_customer_payment_profile_id", :unique => true

  create_table "phone_numbers", :force => true do |t|
    t.integer  "phonable_id",                      :null => false
    t.string   "phonable_type",                    :null => false
    t.string   "phone_number",                     :null => false
    t.boolean  "primary",       :default => false, :null => false
    t.boolean  "cell_phone",    :default => false, :null => false
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
  end

  create_table "stores", :force => true do |t|
    t.string   "username",                       :default => "", :null => false
    t.string   "email",                          :default => "", :null => false
    t.string   "encrypted_password",             :default => "", :null => false
    t.string   "name",                                           :null => false
    t.string   "employer_identification_number",                 :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                  :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.integer  "failed_attempts",                :default => 0
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.string   "authentication_token"
    t.datetime "created_at",                                     :null => false
    t.datetime "updated_at",                                     :null => false
  end

  add_index "stores", ["authentication_token"], :name => "index_stores_on_authentication_token", :unique => true
  add_index "stores", ["confirmation_token"], :name => "index_stores_on_confirmation_token", :unique => true
  add_index "stores", ["email"], :name => "index_stores_on_email", :unique => true
  add_index "stores", ["reset_password_token"], :name => "index_stores_on_reset_password_token", :unique => true
  add_index "stores", ["unlock_token"], :name => "index_stores_on_unlock_token", :unique => true
  add_index "stores", ["username"], :name => "index_stores_on_username", :unique => true

end
