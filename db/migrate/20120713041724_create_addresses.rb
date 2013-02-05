class CreateAddresses < ActiveRecord::Migration
  def change
    create_table :addresses do |t|
      t.references :addressable,     :polymorphic => true, :null => false
      t.string :address_type,        :null => false, :default => ""
      t.string :street,              :null => false, :default => ""
      t.string :city,                :null => false, :default => ""
      t.string :state,               :null => false, :default => ""
      t.string :zip_code,            :null => false, :default => ""
      t.string :country,             :null => false, :default => ""
      t.float :latitude
      t.float :longitude

      t.timestamps
    end
  end
end