class CreateDebits < ActiveRecord::Migration
  def change
    create_table :debits do |t|
      t.references :ledger,           :null => false
      t.string :type,                 :null => false
      t.datetime :date,               :null => false
      t.datetime :due_date,           :null => false
      t.decimal :amount,              :null => false, :precision => 15, :scale => 2

      t.timestamps
    end
  end
end
