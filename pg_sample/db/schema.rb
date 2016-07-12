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

ActiveRecord::Schema.define(version: 20160507045500) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "file_part_upload_file_entities", force: :cascade do |t|
    t.string   "original"
    t.string   "mime"
    t.string   "kind"
    t.string   "token"
    t.string   "meta"
    t.integer  "saved_size"
    t.boolean  "merged",     default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "file_part_upload_transcoding_records", force: :cascade do |t|
    t.string   "name"
    t.string   "fops"
    t.string   "quniu_persistance_id"
    t.string   "token"
    t.string   "status"
    t.string   "meta"
    t.integer  "saved_size"
    t.boolean  "merged",               default: false
    t.integer  "file_entity_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "file_part_upload_transcoding_records", ["file_entity_id"], name: "index_file_part_upload_transcoding_records_on_file_entity_id", using: :btree

end
