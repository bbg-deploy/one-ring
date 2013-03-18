class CreateEntries < ActiveRecord::Migration
  def change
    create_table :entries do |t|
      t.references :ledger,           :null => false
      t.references :debit,            :null => false
      t.references :credit,           :null => false
      t.decimal :amount,              :null => false, :default => 0, :precision => 15, :scale => 2

      t.timestamps
    end
  end
end
