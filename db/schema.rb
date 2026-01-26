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

ActiveRecord::Schema[8.0].define(version: 2026_01_26_015222) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "user_words", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "word_id", null: false
    t.boolean "memorized"
    t.integer "quiz_count"
    t.integer "correct_count"
    t.datetime "last_studied_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["last_studied_at"], name: "index_user_words_on_last_studied_at"
    t.index ["memorized"], name: "index_user_words_on_memorized"
    t.index ["user_id", "word_id"], name: "index_user_words_on_user_id_and_word_id", unique: true
    t.index ["user_id"], name: "index_user_words_on_user_id"
    t.index ["word_id"], name: "index_user_words_on_word_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "password_digest"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  create_table "word_taggings", force: :cascade do |t|
    t.bigint "word_id", null: false
    t.bigint "word_tag_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["word_id", "word_tag_id"], name: "index_word_taggings_on_word_id_and_word_tag_id", unique: true
    t.index ["word_id"], name: "index_word_taggings_on_word_id"
    t.index ["word_tag_id"], name: "index_word_taggings_on_word_tag_id"
  end

  create_table "word_tags", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.string "color", default: "#4CAF50"
    t.string "category", default: "custom"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "words_count"
    t.index ["name"], name: "index_word_tags_on_name", unique: true, where: "(user_id IS NULL)"
    t.index ["user_id", "name"], name: "index_word_tags_on_user_id_and_name", unique: true, where: "(user_id IS NOT NULL)"
    t.index ["user_id"], name: "index_word_tags_on_user_id"
  end

  create_table "words", force: :cascade do |t|
    t.string "japanese", null: false
    t.string "reading"
    t.string "english", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["japanese"], name: "index_words_on_japanese", unique: true
  end

  add_foreign_key "user_words", "users"
  add_foreign_key "user_words", "words"
  add_foreign_key "word_taggings", "word_tags"
  add_foreign_key "word_taggings", "words"
  add_foreign_key "word_tags", "users"
end
