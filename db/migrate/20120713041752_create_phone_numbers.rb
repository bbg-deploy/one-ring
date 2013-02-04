class CreatePhoneNumbers < ActiveRecord::Migration
  def change
    create_table :phone_numbers do |t|
      t.references :phonable, :polymorphic => true, :null => false
      t.string :phone_number,   :null => false
      t.boolean :primary,       :null => false, :default => false
      t.boolean :cell_phone,    :null => false, :default => false

      t.timestamps
    end
  end
end