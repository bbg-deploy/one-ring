class CreateAnalystRoles < ActiveRecord::Migration
  def change
    create_table :analyst_roles do |t|
      t.string :name,       :null => false
      t.text :description,  :null => false, :default => ""
      t.boolean :permanent, :null => false, :default => false

      t.timestamps
    end
  end
end
