class CreateAgentAssignments < ActiveRecord::Migration
  def change
    create_table :agent_assignments do |t|
      t.references :agent,          :null => false
      t.references :agent_role,     :null => false

      t.timestamps
    end
  end
end