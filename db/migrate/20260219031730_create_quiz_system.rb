class CreateQuizSystem < ActiveRecord::Migration[8.0]
  def change
    create_table :quiz_sessions do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :word_order, array: true, default: []
      t.integer :current_index, default: 0
      t.string :status, default: "in_progress"
      t.integer :score, default: 0
      t.datetime :recently_worked


      t.timestamps
    end

    create_table :user_answers do |t|
      t.references :quiz_session, null: false, foreign_key: true
      t.references :word, null: false, foreign_key: true
      t.string :selected_answer, null: false
      t.boolean :is_correct, null: false
    end
  end
end
