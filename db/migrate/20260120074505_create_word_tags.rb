class CreateWordTags < ActiveRecord::Migration[8.0]
  def change
    create_table :word_tags do |t|
      t.string :name, null: false
      t.text :description
      t.string :color, default: "#4CAF50"
      t.string :category, default: "custom"
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
    
    add_index :word_tags, :name, unique: true, where: "user_id IS NULL"

    add_index :word_tags, [:user_id, :name], unique: true, where: "user_id IS NOT NULL"
  end
end
