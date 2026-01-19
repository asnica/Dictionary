class CreateUserWords < ActiveRecord::Migration[8.0]
  def change
    create_table :user_words do |t|
      t.references :user, null: false, foreign_key: true
      t.references :word, null: false, foreign_key: true
      t.boolean :memorized
      t.integer :quiz_count
      t.integer :correct_count
      t.datetime :last_studied_at

      t.timestamps
    end

    add_indexx :user_words, [:user_id, :word_id], unique: true

    add_index :user_words, :memorized

    add_index : :user_words, :last_studied_at
  end
end
