class CreateClients < ActiveRecord::Migration
  def change
    create_table :clients do |t|
      t.string :name,                   :null => false
      t.string :app_id,                 :null => false
      t.string :app_access_token,       :null => false

      t.timestamps
    end

    add_index :clients, :app_id,               :unique => true
    add_index :clients, :app_access_token,     :unique => true
  end
end
