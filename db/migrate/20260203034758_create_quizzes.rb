class CreateQuizzes < ActiveRecord::Migration[8.0]
  def change
    create_table :quizzes do |t|
      t.references :user, null: false, foreign_key: true

      t.string :status, default: 'not_started', null: false
      t.integer :total_questions, default: 10, null: false
      t.integer :current_questions_number, default: 0, null: false
      t.integer :score
      t.datetime :started_at
      t.datetime :completed_at

      t.timestamps
    end
    add_index :quizzes, :status
    add_index :quizzes, [ :user_id, :status ]
  end
end
