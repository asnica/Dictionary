class CreateSynonyms < ActiveRecord::Migration[8.0]
  def change
    create_table :synonyms do |t|
      t.references :word, null: false, foreign_key: true
      t.string :synonym_word, null: false

      t.timestamps
    end
    add_index :synonyms, [ :word_id, :synonym_word ], unique: true
  end
end
