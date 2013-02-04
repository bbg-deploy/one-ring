class CreateAgentRoles < ActiveRecord::Migration
  def change
    create_table :agent_roles do |t|
      t.string :name,       :null => false
      t.text :description,  :null => false, :default => ""
      t.boolean :permanent, :null => false, :default => false

      t.timestamps
    end
  end
end
