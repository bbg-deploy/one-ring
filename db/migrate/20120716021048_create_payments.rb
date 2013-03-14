class CreatePayments < ActiveRecord::Migration
  def change
    create_table :payments do |t|
      t.references :customer,                        :null => false
      t.references :payment_profile,                 :null => false
      t.string :cim_customer_payment_profile_id,     :null => false
      t.decimal :amount,                             :null => false

      t.timestamps
    end
  end
end
