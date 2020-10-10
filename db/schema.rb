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

ActiveRecord::Schema.define(version: 2020_10_10_145147) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "episode_records", force: :cascade do |t|
    t.string "access_key", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.json "data"
    t.index ["access_key"], name: "index_episode_records_on_access_key", unique: true
  end

  create_table "translation_caches", force: :cascade do |t|
    t.string "key", limit: 40, null: false
    t.text "original", null: false
    t.json "translations", default: {}, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["key"], name: "index_translation_caches_on_key"
  end

end
