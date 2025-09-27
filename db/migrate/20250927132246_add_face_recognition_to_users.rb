class AddFaceRecognitionToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :face_encoding_data, :text
    add_column :users, :face_photo_url, :string
  end
end
