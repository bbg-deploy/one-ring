class CreateTermsOptions < ActiveRecord::Migration
  def change
    create_table :terms_options do |t|
      t.references :application,                   :null => false
      t.string :payment_frequency,                 :null => false
      t.decimal :markup,                           :null => false
      t.integer :number_of_payments,               :null => false
      t.decimal :payment_amount,                   :null => false

      t.timestamps
    end
  end
end
