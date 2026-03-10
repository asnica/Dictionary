class CreateInitialSchema < ActiveRecord::Migration[8.0]
  def change
    # PostgreSQL Extensions
    enable_extension "pg_catalog.plpgsql"
    

    create_table "active_storage_blobs", force: :cascade do |t|
      t.string "key", null: false
      t.string "filename", null: false
      t.string "content_type"
      t.text "metadata"
      t.string "service_name", null: false
      t.bigint "byte_size", null: false
      t.string "checksum"
      t.datetime "created_at", null: false
      t.index [ "key" ], name: "index_active_storage_blobs_on_key", unique: true
    end

    create_table "active_storage_attachments", force: :cascade do |t|
      t.string "name", null: false
      t.string "record_type", null: false
      t.bigint "record_id", null: false
      t.bigint "blob_id", null: false
      t.datetime "created_at", null: false
      t.index [ "blob_id" ], name: "index_active_storage_attachments_on_blob_id"
      t.index [ "record_type", "record_id", "name", "blob_id" ], name: "index_active_storage_attachments_uniqueness", unique: true
    end

    create_table "active_storage_variant_records", force: :cascade do |t|
      t.bigint "blob_id", null: false
      t.string "variation_digest", null: false
      t.index [ "blob_id", "variation_digest" ], name: "index_active_storage_variant_records_uniqueness", unique: true
    end

    create_table "users", force: :cascade do |t|
      t.string "name"
      t.string "email"
      t.string "password_digest"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.datetime "confirmed_at"
      t.string "confirmation_token"
      t.index [ "confirmation_token" ], name: "index_users_on_confirmation_token", unique: true
    end

    create_table "words", force: :cascade do |t|
      t.string "japanese", null: false
      t.string "reading"
      t.string "english", null: false
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.boolean "active", default: true, null: false
    end

    create_table "quiz_sessions", force: :cascade do |t|
      t.bigint "user_id", null: false
      t.integer "word_order", default: [], array: true
      t.integer "current_index", default: 0
      t.string "status", default: "in_progress"
      t.integer "score", default: 0
      t.datetime "recently_worked"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.json "choice_order", default: {}
      t.index [ "user_id" ], name: "index_quiz_sessions_on_user_id"
    end

    create_table "synonyms", force: :cascade do |t|
      t.bigint "word_id", null: false
      t.string "synonym_word"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.index [ "word_id" ], name: "index_synonyms_on_word_id"
    end

    create_table "user_answers", force: :cascade do |t|
      t.bigint "quiz_session_id", null: false
      t.bigint "word_id", null: false
      t.string "selected_answer"
      t.boolean "is_correct", null: false
      t.index [ "quiz_session_id" ], name: "index_user_answers_on_quiz_session_id"
      t.index [ "word_id" ], name: "index_user_answers_on_word_id"
    end

    create_table "user_words", force: :cascade do |t|
      t.bigint "user_id", null: false
      t.bigint "word_id", null: false
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.index [ "user_id" ], name: "index_user_words_on_user_id"
      t.index [ "word_id" ], name: "index_user_words_on_word_id"
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
      t.index [ "name" ], name: "index_word_tags_on_name", unique: true, where: "(user_id IS NULL)"
      t.index [ "user_id", "name" ], name: "index_word_tags_on_user_id_and_name", unique: true, where: "(user_id IS NOT NULL)"
      t.index [ "user_id" ], name: "index_word_tags_on_user_id"
    end

    create_table "word_taggings", force: :cascade do |t|
      t.bigint "word_id", null: false
      t.bigint "word_tag_id", null: false
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.index [ "word_id", "word_tag_id" ], name: "index_word_taggings_on_word_id_and_word_tag_id", unique: true
      t.index [ "word_id" ], name: "index_word_taggings_on_word_id"
      t.index [ "word_tag_id" ], name: "index_word_taggings_on_word_tag_id"
    end

    # Foreign Keys
    add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
    add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
    add_foreign_key "quiz_sessions", "users"
    add_foreign_key "synonyms", "words"
    add_foreign_key "user_answers", "quiz_sessions"
    add_foreign_key "user_answers", "words"
    add_foreign_key "user_words", "users"
    add_foreign_key "user_words", "words"
    add_foreign_key "word_taggings", "word_tags"
    add_foreign_key "word_taggings", "words"
    add_foreign_key "word_tags", "users"
  end
end
