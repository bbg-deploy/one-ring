class CreatePaymentProfiles < ActiveRecord::Migration
  def change
    create_table :payment_profiles do |t|
      t.references :customer,                        :null => false
      t.string :payment_type,                        :null => false
      t.string :first_name,                          :null => false
      t.string :last_name,                           :null => false
      t.string :last_four_digits,                    :null => false
      t.string :cim_customer_payment_profile_id

      t.timestamps
    end

    add_index :payment_profiles, :cim_customer_payment_profile_id,  :unique => true
  end
end
