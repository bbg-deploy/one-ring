class CreateContracts < ActiveRecord::Migration
  def change
    create_table :contracts do |t|
      t.string :customer_account_number,   :null => false
      t.string :application_number,        :null => false
      t.string :contract_number,           :null => false

      t.timestamps
    end

    add_index :contracts, :application_number,   :unique => true
  end
end
