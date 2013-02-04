class CreateIncomeSources < ActiveRecord::Migration
  def change
    create_table :income_sources do |t|
      t.references :customer,                        :null => false
      t.string :name,                                :null => false
      t.string :employer_name,                       :null => false
      t.string :employer_phone_number,               :null => false
      t.decimal :monthly_income,                     :null => false, :default => 0

      t.timestamps
    end
  end
end
