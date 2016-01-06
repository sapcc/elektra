# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20160106132424) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "friendly_id_entries", force: :cascade do |t|
    t.string   "class_name"
    t.string   "scope"
    t.string   "name"
    t.string   "slug"
    t.string   "key"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "endpoint"
  end

  add_index "friendly_id_entries", ["class_name", "key"], name: "index_friendly_id_entries_on_class_name_and_key", using: :btree
  add_index "friendly_id_entries", ["class_name", "scope", "key"], name: "index_friendly_id_entries_on_class_name_and_scope_and_key", using: :btree
  add_index "friendly_id_entries", ["class_name"], name: "index_friendly_id_entries_on_class_name", using: :btree
  add_index "friendly_id_entries", ["key"], name: "index_friendly_id_entries_on_key", using: :btree
  add_index "friendly_id_entries", ["scope"], name: "index_friendly_id_entries_on_scope", using: :btree
  add_index "friendly_id_entries", ["slug"], name: "index_friendly_id_entries_on_slug", using: :btree

  create_table "inquiry_inquiries", force: :cascade do |t|
    t.string   "kind"
    t.text     "description"
    t.json     "payload"
    t.string   "aasm_state"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.string   "project_id"
    t.string   "domain_id"
    t.json     "callbacks"
    t.integer  "requester_id"
  end

  create_table "inquiry_inquiries_processors", id: false, force: :cascade do |t|
    t.integer "inquiry_id",   null: false
    t.integer "processor_id", null: false
  end

  add_index "inquiry_inquiries_processors", ["inquiry_id", "processor_id"], name: "index_inquiry_processor", using: :btree
  add_index "inquiry_inquiries_processors", ["processor_id", "inquiry_id"], name: "index_processor_inquiry", using: :btree

  create_table "inquiry_process_steps", force: :cascade do |t|
    t.string   "from_state"
    t.string   "to_state"
    t.string   "event"
    t.text     "description"
    t.integer  "inquiry_id"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.integer  "processor_id"
  end

  add_index "inquiry_process_steps", ["inquiry_id"], name: "index_inquiry_process_steps_on_inquiry_id", using: :btree

  create_table "inquiry_processors", force: :cascade do |t|
    t.string   "uid"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string   "email"
    t.string   "full_name"
  end

  create_table "resource_management_capacities", force: :cascade do |t|
    t.string   "cluster_id"
    t.string   "service"
    t.string   "resource"
    t.integer  "value",      limit: 8
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  add_index "resource_management_capacities", ["service", "resource"], name: "resource_management_capacities_master_index", using: :btree

  create_table "resource_management_resources", force: :cascade do |t|
    t.string   "cluster_id"
    t.string   "domain_id"
    t.string   "project_id"
    t.string   "service"
    t.string   "name"
    t.integer  "current_quota",  limit: 8
    t.integer  "approved_quota", limit: 8
    t.integer  "usage",          limit: 8
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  add_index "resource_management_resources", ["domain_id", "project_id", "service", "name"], name: "resource_management_resources_master_index", using: :btree

  create_table "sessions", force: :cascade do |t|
    t.string   "session_id", null: false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], name: "index_sessions_on_session_id", unique: true, using: :btree
  add_index "sessions", ["updated_at"], name: "index_sessions_on_updated_at", using: :btree

end
