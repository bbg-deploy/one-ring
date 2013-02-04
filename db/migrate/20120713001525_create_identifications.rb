class CreateIdentifications < ActiveRecord::Migration
  def change
    create_table(:identifications) do |t|
      t.references :customer,             :null => false
      t.string :identification_type,      :null => false, :default => ""
      t.string :authority,                :null => false, :default => ""
      t.string :identification_number,    :null => false, :default => ""

      t.timestamps
    end
  end
end