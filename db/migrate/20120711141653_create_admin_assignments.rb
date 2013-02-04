class CreateAdminAssignments < ActiveRecord::Migration
  def change
    create_table :admin_assignments do |t|
      t.references :admin,          :null => false
      t.references :admin_role,     :null => false

      t.timestamps
    end
  end
end