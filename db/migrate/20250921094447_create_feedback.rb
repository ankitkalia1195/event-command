class CreateFeedback < ActiveRecord::Migration[8.0]
  def change
    create_table :feedbacks do |t|
      t.references :user, null: false, foreign_key: true
      t.references :session, null: true, foreign_key: true # null for overall event feedback
      t.integer :rating, null: false # 1-5 stars
      t.text :comment

      t.timestamps
    end
    add_index :feedbacks, [ :user_id, :session_id ], unique: true
    add_index :feedbacks, :rating
  end
end
