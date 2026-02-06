class AddRecentlyWorkedToQuizzes < ActiveRecord::Migration[8.0]
  def change
    add_column :quizzes, :recently_worked, :datetime, null: true
  end
end
