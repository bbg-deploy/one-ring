class CreateStores < ActiveRecord::Migration
  def change
    create_table(:stores) do |t|
      ## Strings to capture user names
      t.string :username,           :null => false, :default => ""

      ## Database authenticatable
      t.string :email,              :null => false, :default => ""
      t.string :encrypted_password, :null => false, :default => ""

      ## Profile Information
      t.string :name,                           :null => false
      t.string :employer_identification_number, :null => false

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

    add_index :stores, :username,             :unique => true
    add_index :stores, :email,                :unique => true
    add_index :stores, :reset_password_token, :unique => true
    add_index :stores, :confirmation_token,   :unique => true
    add_index :stores, :unlock_token,         :unique => true
    add_index :stores, :authentication_token, :unique => true
  end
end