class CreateApplications < ActiveRecord::Migration
  def change
    create_table :applications do |t|
      t.string :application_number,       :null => false
      t.string :customer_account_number
      t.string :store_account_number,     :null => false
      t.string :matching_email,           :null => false
      t.string :state,                    :null => false
      t.datetime :time_at_address
      t.string :rent_or_own
      t.decimal :rent_payment
      t.boolean :id_verified,             :null => false, :default => false

      t.timestamps
    end
  end
end
