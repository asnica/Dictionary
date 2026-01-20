class CreateWordTaggings < ActiveRecord::Migration[8.0]
  def change
    create_table :word_taggings do |t|
      t.references :word, null: false, foreign_key: true
      t.references :word_tag, null: false, foreign_key: true

      t.timestamps
    end

    add_index :word_taggings, [:word_id, :word_tag_id], unique: true
  end
end
