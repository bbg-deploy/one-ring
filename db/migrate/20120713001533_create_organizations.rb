class CreateOrganizations < ActiveRecord::Migration
  def change
    create_table(:organizations) do |t|
      t.string :name,           :null => false, :default => ""
      t.string :website,        :null => false, :default => ""

      t.timestamps
    end

    add_index :organizations, :name,             :unique => true
    add_index :organizations, :website,          :unique => true
  end
end