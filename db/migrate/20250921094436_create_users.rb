class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.string :name, null: false
      t.string :email, null: false
      t.string :role, default: 'attendee', null: false
      t.boolean :checked_in, default: false, null: false
      t.boolean :is_speaker, default: false, null: false

      t.timestamps
    end
    add_index :users, :email, unique: true
    add_index :users, :role
  end
end
