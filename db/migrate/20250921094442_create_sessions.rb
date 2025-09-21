class CreateSessions < ActiveRecord::Migration[8.0]
  def change
    create_table :sessions do |t|
      t.string :title, null: false
      t.text :abstract
      t.datetime :start_time, null: false
      t.datetime :end_time, null: false
      t.references :speaker, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end
    add_index :sessions, :start_time
    add_index :sessions, [:start_time, :end_time]
  end
end
