class CreateLoginTokens < ActiveRecord::Migration[8.0]
  def change
    create_table :login_tokens do |t|
      t.references :user, null: false, foreign_key: true
      t.string :token, null: false
      t.datetime :expires_at, null: false
      t.boolean :used, default: false, null: false

      t.timestamps
    end
    add_index :login_tokens, :token, unique: true
    add_index :login_tokens, :expires_at
    add_index :login_tokens, :used
  end
end
