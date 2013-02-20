class CreateAccessGrants < ActiveRecord::Migration
  def change
    create_table :access_grants do |t|
      t.references :accessible,     :polymorphic => true, :null => false
      t.references :client,         :null => false
      t.string :code
      t.string :access_token
      t.string :refresh_token
      t.string :state
      t.datetime :access_token_expires_at

      t.timestamps
    end
  end
end
