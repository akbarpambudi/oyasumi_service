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

ActiveRecord::Schema[8.0].define(version: 2025_04_10_135436) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "relationship_records", force: :cascade do |t|
    t.integer "follower_id"
    t.integer "followed_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "sleep_record_records", force: :cascade do |t|
    t.datetime "start_time"
    t.datetime "end_time"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "metadata", default: {}
    t.index ["created_at"], name: "index_sleep_record_records_on_created_at"
    t.index ["end_time"], name: "index_sleep_record_records_on_end_time"
    t.index ["metadata"], name: "index_sleep_record_records_on_metadata", using: :gin
    t.index ["start_time"], name: "index_sleep_record_records_on_start_time"
    t.index ["user_id", "end_time"], name: "index_sleep_record_records_on_user_id_and_end_time"
    t.index ["user_id", "start_time", "end_time"], name: "idx_on_user_id_start_time_end_time_9cadadfa64"
    t.index ["user_id", "start_time"], name: "index_sleep_record_records_on_user_id_and_start_time"
    t.index ["user_id"], name: "index_sleep_record_records_on_user_id"
  end

  create_table "solid_cable_messages", force: :cascade do |t|
    t.binary "channel", null: false
    t.binary "payload", null: false
    t.datetime "created_at", null: false
    t.bigint "channel_hash", null: false
    t.index ["channel"], name: "index_solid_cable_messages_on_channel"
    t.index ["channel_hash"], name: "index_solid_cable_messages_on_channel_hash"
    t.index ["created_at"], name: "index_solid_cable_messages_on_created_at"
  end

  create_table "user_records", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "encrypted_password"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_user_records_on_created_at"
    t.index ["email"], name: "index_user_records_on_email", unique: true
  end
end
