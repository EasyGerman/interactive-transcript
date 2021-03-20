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

ActiveRecord::Schema.define(version: 2021_03_20_120805) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "episode_records", force: :cascade do |t|
    t.string "access_key", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.json "data"
    t.bigint "podcast_id", null: false
    t.string "short_name"
    t.index ["podcast_id", "access_key"], name: "index_episode_records_on_podcast_id_and_access_key", unique: true
    t.index ["podcast_id"], name: "index_episode_records_on_podcast_id"
  end

  create_table "feedbacks", force: :cascade do |t|
    t.boolean "outcome", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "podcasts", force: :cascade do |t|
    t.string "code", null: false
    t.string "name", null: false
    t.string "lang", null: false
    t.string "host", null: false
    t.string "feed_url", null: false
    t.json "settings", default: {}, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["code"], name: "index_podcasts_on_code", unique: true
  end

  create_table "translation_caches", force: :cascade do |t|
    t.string "key", limit: 40, null: false
    t.text "original", null: false
    t.json "translations", default: {}, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "podcast_id", default: 1, null: false
    t.index ["podcast_id", "key"], name: "index_translation_caches_on_podcast_id_and_key", unique: true
    t.index ["podcast_id"], name: "index_translation_caches_on_podcast_id"
  end

  create_table "translations", force: :cascade do |t|
    t.string "key", limit: 40, null: false
    t.bigint "translation_cache_id", null: false
    t.string "source_lang", null: false
    t.string "lang", null: false
    t.string "region"
    t.string "translation_service", null: false
    t.integer "source_length", null: false
    t.datetime "translated_at"
    t.string "body", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["key", "lang"], name: "index_translations_on_key_and_lang"
    t.index ["translated_at"], name: "index_translations_on_translated_at"
    t.index ["translation_cache_id"], name: "index_translations_on_translation_cache_id"
  end

  create_table "vocab_slide_records", force: :cascade do |t|
    t.bigint "episode_record_id", null: false
    t.string "chapter_key", limit: 10, null: false
    t.binary "data"
    t.datetime "uploaded_at"
    t.index ["episode_record_id", "chapter_key"], name: "index_vocab_slide_records_on_episode_record_id_and_chapter_key", unique: true
  end

  add_foreign_key "episode_records", "podcasts"
  add_foreign_key "translation_caches", "podcasts"
  add_foreign_key "translations", "translation_caches", column: "translation_cache_id"
  add_foreign_key "vocab_slide_records", "episode_records"
end
