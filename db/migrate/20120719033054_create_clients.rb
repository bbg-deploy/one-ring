class CreateClients < ActiveRecord::Migration
  def change
    create_table :clients do |t|
      t.string :name,                   :null => false
      t.string :app_id,                 :null => false
      t.string :app_access_token,       :null => false
      t.string :redirect_uri,          :null => false

      t.timestamps
    end

    add_index :clients, :app_id,               :unique => true
    add_index :clients, :app_access_token,     :unique => true
    add_index :clients, :redirect_uri,         :unique => true
  end
end
