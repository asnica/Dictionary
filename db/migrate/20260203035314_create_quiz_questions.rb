class CreateQuizQuestions < ActiveRecord::Migration[8.0]
  def change
    create_table :quiz_questions do |t|
      t.references :quiz, null: false, foreign_key: true
      t.references :word, null: false, foreign_key: true

      t.string :user_answer
      t.boolean :is_correct
      t.json :choices

      t.timestamps
    end
    add_index :quiz_questions, [ :quiz_id, :word_id ], unique: true
  end
end
