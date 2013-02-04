class CreateAnalystAssignments < ActiveRecord::Migration
  def change
    create_table :analyst_assignments do |t|
      t.references :analyst,          :null => false
      t.references :analyst_role,     :null => false

      t.timestamps
    end
  end
end