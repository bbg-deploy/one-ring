class CreateClients < ActiveRecord::Migration
  def change
    create_table :clients do |t|
      t.string :name
      t.string :app_id
      t.string :app_access_token

      t.timestamps
    end
  end
end
