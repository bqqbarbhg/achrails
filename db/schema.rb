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

ActiveRecord::Schema.define(version: 20151014132622) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "groups", force: :cascade do |t|
    t.string   "name",                    null: false
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.integer  "visibility",  default: 0
    t.text     "description"
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
    t.string   "sss_group"
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

  create_table "users", force: :cascade do |t|
    t.string   "email",               default: ""
    t.datetime "remember_created_at"
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.string   "provider",                         null: false
    t.string   "uid",                              null: false
    t.string   "name"
    t.text     "bearer_token"
    t.string   "person_id"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree

  create_table "video_manifests", force: :cascade do |t|
    t.uuid     "uuid",          null: false
    t.json     "manifest_json", null: false
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.integer  "revision"
    t.string   "video_url"
    t.text     "searchable"
  end

  add_index "video_manifests", ["uuid"], name: "index_video_manifests_on_uuid", unique: true, using: :btree

  create_table "videos", force: :cascade do |t|
    t.integer  "author_id"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.string   "title"
    t.integer  "revision",      default: 1, null: false
    t.uuid     "uuid"
    t.json     "manifest_json"
    t.string   "video_url"
    t.text     "searchable"
  end

  add_index "videos", ["uuid"], name: "index_videos_on_uuid", unique: true, using: :btree

end
