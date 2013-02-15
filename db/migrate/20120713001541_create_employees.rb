class CreateEmployees < ActiveRecord::Migration
  def change
    create_table(:employees) do |t|
      ## Strings to capture user names
      t.string :username,           :null => false, :default => ""

      ## Database authenticatable
      t.string :email,              :null => false, :default => ""
      t.string :encrypted_password, :null => false, :default => ""

      ## Profile Information
      t.string :first_name,             :null => false
      t.string :middle_name
      t.string :last_name,              :null => false
      t.date   :date_of_birth,          :null => false

      ## Recoverable
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at

      ## Rememberable
      t.datetime :remember_created_at

      ## Trackable
      t.integer  :sign_in_count, :default => 0
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.string   :current_sign_in_ip
      t.string   :last_sign_in_ip

      ## Confirmable
      t.string   :confirmation_token
      t.datetime :confirmed_at
      t.datetime :confirmation_sent_at
      t.string   :unconfirmed_email # Only if using reconfirmable

      ## Lockable
      t.integer  :failed_attempts, :default => 0 # Only if lock strategy is :failed_attempts
      t.string   :unlock_token # Only if unlock strategy is :email or :both
      t.datetime :locked_at

      ## Token authenticatable
      t.string :authentication_token

      ## Cancelable
      t.datetime :cancelled_at #Allows for me to let customers cancel accounts

      t.timestamps
    end

    add_index :employees, :username,             :unique => true
    add_index :employees, :email,                :unique => true
    add_index :employees, :reset_password_token, :unique => true
    add_index :employees, :confirmation_token,   :unique => true
    add_index :employees, :unlock_token,         :unique => true
    add_index :employees, :authentication_token, :unique => true
  end
end