class DropMultipleTables < ActiveRecord::Migration[8.0]
  def change
    drop_table :quiz_questions
    drop_table :quiz_templates
    drop_table :quizzes
  end
end
