class CreateCredits < ActiveRecord::Migration
  def change
    create_table :credits do |t|
      t.references :ledger,           :null => false
      t.string :cim_payment_profile_id
      t.string :type,                 :null => false
      t.datetime :date,               :null => false
      t.decimal :amount,              :null => false

      t.timestamps
    end
  end
end
