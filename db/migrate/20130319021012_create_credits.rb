class CreateCredits < ActiveRecord::Migration
  def change
    create_table :credits do |t|
      t.references :ledger,           :null => false
      t.string :type,                 :null => false
      t.datetime :date,               :null => false
      t.string :payment_profile_id
      t.decimal :amount,              :null => false

      t.timestamps
    end
  end
end
