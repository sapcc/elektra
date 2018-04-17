# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20180417090223) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "domain_profiles", id: :serial, force: :cascade do |t|
    t.string "domain_id"
    t.integer "user_profile_id"
    t.string "tou_version"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_profile_id"], name: "index_domain_profiles_on_user_profile_id"
  end

  create_table "friendly_id_entries", id: :serial, force: :cascade do |t|
    t.string "class_name"
    t.string "scope"
    t.string "name"
    t.string "slug"
    t.string "key"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "endpoint"
    t.index ["class_name", "key"], name: "index_friendly_id_entries_on_class_name_and_key"
    t.index ["class_name", "scope", "key"], name: "index_friendly_id_entries_on_class_name_and_scope_and_key"
    t.index ["class_name"], name: "index_friendly_id_entries_on_class_name"
    t.index ["key"], name: "index_friendly_id_entries_on_key"
    t.index ["scope"], name: "index_friendly_id_entries_on_scope"
    t.index ["slug"], name: "index_friendly_id_entries_on_slug"
  end

  create_table "inquiry_inquiries", id: :serial, force: :cascade do |t|
    t.string "kind"
    t.text "description"
    t.json "payload"
    t.string "aasm_state"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "project_id"
    t.string "domain_id"
    t.json "callbacks"
    t.integer "requester_id"
    t.json "tags"
    t.string "approver_domain_id"
  end

  create_table "inquiry_inquiries_processors", id: false, force: :cascade do |t|
    t.integer "inquiry_id", null: false
    t.integer "processor_id", null: false
    t.index ["inquiry_id", "processor_id"], name: "index_inquiry_processor"
    t.index ["processor_id", "inquiry_id"], name: "index_processor_inquiry"
  end

  create_table "inquiry_process_steps", id: :serial, force: :cascade do |t|
    t.string "from_state"
    t.string "to_state"
    t.string "event"
    t.text "description"
    t.integer "inquiry_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "processor_id"
    t.index ["inquiry_id"], name: "index_inquiry_process_steps_on_inquiry_id"
  end

  create_table "inquiry_processors", id: :serial, force: :cascade do |t|
    t.string "uid"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "email"
    t.string "full_name"
    t.string "name"
  end

  create_table "object_cache", id: :string, force: :cascade do |t|
    t.string "name"
    t.string "project_id"
    t.string "domain_id"
    t.string "cached_object_type"
    t.json "payload"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cached_object_type"], name: "index_object_cache_on_cached_object_type"
    t.index ["id"], name: "index_object_cache_on_id"
    t.index ["name"], name: "index_object_cache_on_name"
    t.index ["project_id"], name: "index_object_cache_on_project_id"
  end

  create_table "project_profiles", id: :serial, force: :cascade do |t|
    t.string "project_id"
    t.text "wizard_payload"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "sessions", id: :serial, force: :cascade do |t|
    t.string "session_id", null: false
    t.text "data"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["session_id"], name: "index_sessions_on_session_id", unique: true
    t.index ["updated_at"], name: "index_sessions_on_updated_at"
  end

  create_table "user_profiles", id: :serial, force: :cascade do |t|
    t.string "uid"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.string "email"
    t.string "full_name"
    t.index ["name"], name: "index_user_profiles_on_name"
    t.index ["uid"], name: "index_user_profiles_on_uid"
  end

  add_foreign_key "domain_profiles", "user_profiles"
end
