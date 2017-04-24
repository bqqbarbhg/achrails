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

ActiveRecord::Schema.define(version: 20170424160339) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "groups", force: :cascade do |t|
    t.string   "name",                    null: false
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.integer  "visibility",  default: 0
    t.text     "description"
    t.string   "sss_id"
  end

  create_table "groups_videos", id: false, force: :cascade do |t|
    t.integer "group_id", null: false
    t.integer "video_id", null: false
  end

  add_index "groups_videos", ["group_id", "video_id"], name: "index_groups_videos_on_group_id_and_video_id", unique: true, using: :btree
  add_index "groups_videos", ["video_id", "group_id"], name: "index_groups_videos_on_video_id_and_group_id", unique: true, using: :btree

  create_table "invitations", force: :cascade do |t|
    t.integer  "group_id"
    t.string   "expect_email"
    t.string   "token",        null: false
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  create_table "log_events", force: :cascade do |t|
    t.integer  "user",         null: false
    t.integer  "event_type",   null: false
    t.integer  "event_target", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "extra"
    t.integer  "state"
  end

  create_table "memberships", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "group_id"
    t.boolean  "admin",      default: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  add_index "memberships", ["group_id"], name: "index_memberships_on_group_id", using: :btree
  add_index "memberships", ["user_id"], name: "index_memberships_on_user_id", using: :btree

  create_table "sessions", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "access_token"
    t.string   "refresh_token"
    t.string   "client_id"
    t.string   "code"
    t.datetime "expires_at"
  end

  add_index "sessions", ["access_token"], name: "index_sessions_on_access_token", unique: true, using: :btree
  add_index "sessions", ["code"], name: "index_sessions_on_code", unique: true, using: :btree
  add_index "sessions", ["refresh_token"], name: "index_sessions_on_refresh_token", unique: true, using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",               default: ""
    t.datetime "remember_created_at"
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.string   "provider",                         null: false
    t.string   "uid",                              null: false
    t.string   "name"
    t.text     "bearer_token"
    t.string   "sss_id"
    t.json     "recent_views"
    t.string   "refresh_token"
    t.string   "token"
    t.string   "preferred_username"
    t.string   "upload_token"
    t.string   "registration_ids",    default: [],              array: true
  end

  create_table "video_revision_blocks", force: :cascade do |t|
    t.integer "video_id"
    t.integer "first_num",            null: false
    t.integer "last_num",             null: false
    t.binary  "compressed_revisions", null: false
  end

  add_index "video_revision_blocks", ["video_id"], name: "index_video_revision_blocks_on_video_id", using: :btree

  create_table "videos", force: :cascade do |t|
    t.integer  "author_id"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.string   "title"
    t.uuid     "uuid"
    t.json     "manifest_json"
    t.string   "video_url"
    t.text     "searchable"
    t.integer  "revision_num",                  null: false
    t.boolean  "is_public",     default: false, null: false
    t.integer  "views",         default: 0,     null: false
    t.datetime "deleted_at"
  end

  add_index "videos", ["uuid"], name: "index_videos_on_uuid", unique: true, using: :btree

  create_table "webhooks", force: :cascade do |t|
    t.string   "notification_url"
    t.integer  "group_id"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  add_index "webhooks", ["group_id"], name: "index_webhooks_on_group_id", using: :btree

  add_foreign_key "webhooks", "groups"
end
