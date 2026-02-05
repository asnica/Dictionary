class AddIndexToQuizzesForRanking < ActiveRecord::Migration[8.0]
  def change
    add_index :quizzes, [ :user_id, :status, :score ]
    add_index :quizzes, [ :status, :completed_at ]
  end
end
