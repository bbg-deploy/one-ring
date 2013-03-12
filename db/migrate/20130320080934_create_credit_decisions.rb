class CreateCreditDecisions < ActiveRecord::Migration
  def change
    create_table :credit_decisions do |t|
      t.references :application,                             :null => false
      t.string :status,                                      :null => false

      t.timestamps
    end
  end
end
