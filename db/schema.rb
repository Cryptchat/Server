# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_10_16_132616) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "admin_tokens", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "token", null: false
    t.datetime "last_used_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_admin_tokens_on_user_id", unique: true
  end

  create_table "auth_tokens", force: :cascade do |t|
    t.string "auth_token", null: false
    t.string "previous_auth_token", null: false
    t.bigint "user_id", null: false
    t.datetime "rotated_at", null: false
    t.boolean "seen", default: false, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["auth_token"], name: "index_auth_tokens_on_auth_token", unique: true
    t.index ["previous_auth_token"], name: "index_auth_tokens_on_previous_auth_token", unique: true
    t.index ["user_id"], name: "index_auth_tokens_on_user_id"
  end

  create_table "ephemeral_keys", force: :cascade do |t|
    t.string "key", null: false
    t.bigint "id_on_user_device", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_ephemeral_keys_on_user_id"
  end

  create_table "invites", force: :cascade do |t|
    t.bigint "inviter_id", null: false
    t.string "country_code", limit: 10, null: false
    t.string "phone_number", limit: 50, null: false
    t.datetime "expires_at", null: false
    t.boolean "claimed", default: false, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["country_code", "phone_number"], name: "index_invites_on_country_code_and_phone_number", unique: true
  end

  create_table "messages", force: :cascade do |t|
    t.text "body", null: false
    t.text "mac", null: false
    t.text "iv", null: false
    t.bigint "sender_user_id", null: false
    t.bigint "receiver_user_id", null: false
    t.text "sender_ephemeral_public_key"
    t.bigint "ephemeral_key_id_on_user_device"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "registrations", force: :cascade do |t|
    t.string "verification_token_hash", limit: 64, null: false
    t.string "salt", limit: 32, null: false
    t.string "country_code", limit: 10, null: false
    t.string "phone_number", limit: 50, null: false
    t.bigint "user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["country_code", "phone_number"], name: "index_registrations_on_country_code_and_phone_number", unique: true
  end

  create_table "server_settings", force: :cascade do |t|
    t.string "name", null: false
    t.text "value"
    t.integer "data_type", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["name"], name: "index_server_settings_on_name", unique: true
  end

  create_table "uploads", force: :cascade do |t|
    t.string "sha", null: false
    t.string "extension", limit: 20, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["sha"], name: "index_uploads_on_sha", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "name", limit: 255
    t.string "country_code", limit: 10, null: false
    t.string "phone_number", limit: 50, null: false
    t.string "instance_id"
    t.string "identity_key", null: false
    t.bigint "avatar_id"
    t.boolean "admin", default: false, null: false
    t.boolean "suspended", default: false, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["country_code", "phone_number"], name: "index_users_on_country_code_and_phone_number", unique: true
    t.index ["identity_key"], name: "index_users_on_identity_key", unique: true
    t.index ["instance_id"], name: "index_users_on_instance_id", unique: true
  end

end
