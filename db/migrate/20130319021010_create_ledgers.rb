class CreateLedgers < ActiveRecord::Migration
  def change
    create_table :ledgers do |t|
      t.references :contract,         :null => false
      t.string :type,                 :null => false

      t.timestamps
    end
    
    add_index :ledgers, :contract_id,             :unique => true
  end
end
