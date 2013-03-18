class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.references :application,                             :null => false
      t.string :type,                                        :null => false
      t.string :id_number
      t.string :name,                                        :null => false, :default => ""
      t.decimal :price,                                      :null => false, :default => 0, :precision => 15, :scale => 2
      t.text :description,                                   :null => false, :default => ""

      t.timestamps
    end
  end
end
