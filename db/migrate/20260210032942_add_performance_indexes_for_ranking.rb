class AddPerformanceIndexesForRanking < ActiveRecord::Migration[8.0]
  def change
    add_index :quizzes, [ :user_id, :status, :score ], name: "index_quizzes_on_user_status_score"
  end
end
