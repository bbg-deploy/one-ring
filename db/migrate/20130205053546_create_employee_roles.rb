class CreateEmployeeRoles < ActiveRecord::Migration
  def change
    create_table(:employee_roles) do |t|
      t.string :name

      t.timestamps
    end

    create_table(:employee_assignments, :id => false) do |t|
      t.references :employee
      t.references :employee_role
    end

    add_index(:employee_roles, :name)
    add_index(:employee_assignments, [ :employee_id, :employee_role_id ])
  end
end
