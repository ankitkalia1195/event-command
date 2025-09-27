# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_09_21_094451) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "feedbacks", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "session_id"
    t.integer "rating", null: false
    t.text "comment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["rating"], name: "index_feedbacks_on_rating"
    t.index ["session_id"], name: "index_feedbacks_on_session_id"
    t.index ["user_id", "session_id"], name: "index_feedbacks_on_user_id_and_session_id", unique: true
    t.index ["user_id"], name: "index_feedbacks_on_user_id"
  end

  create_table "login_tokens", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "token", null: false
    t.datetime "expires_at", null: false
    t.boolean "used", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["expires_at"], name: "index_login_tokens_on_expires_at"
    t.index ["token"], name: "index_login_tokens_on_token", unique: true
    t.index ["used"], name: "index_login_tokens_on_used"
    t.index ["user_id"], name: "index_login_tokens_on_user_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.string "title", null: false
    t.text "abstract"
    t.datetime "start_time", null: false
    t.datetime "end_time", null: false
    t.bigint "speaker_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["speaker_id"], name: "index_sessions_on_speaker_id"
    t.index ["start_time", "end_time"], name: "index_sessions_on_start_time_and_end_time"
    t.index ["start_time"], name: "index_sessions_on_start_time"
  end

  create_table "users", force: :cascade do |t|
    t.string "name", null: false
    t.string "email", null: false
    t.string "role", default: "attendee", null: false
    t.boolean "checked_in", default: false, null: false
    t.boolean "is_speaker", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["role"], name: "index_users_on_role"
  end

  add_foreign_key "feedbacks", "sessions"
  add_foreign_key "feedbacks", "users"
  add_foreign_key "login_tokens", "users"
  add_foreign_key "sessions", "users", column: "speaker_id"
end
