class CreateAlertsLists < ActiveRecord::Migration
  def change
    create_table(:alerts_lists) do |t|
      t.references :customer,     :null => false
      t.boolean :mail,            :default => false
      t.boolean :email,           :default => false
      t.boolean :sms,             :default => false
      t.boolean :phone,           :default => false

      t.timestamps
    end
  end
end