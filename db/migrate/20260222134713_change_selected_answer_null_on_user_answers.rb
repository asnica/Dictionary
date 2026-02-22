class ChangeSelectedAnswerNullOnUserAnswers < ActiveRecord::Migration[8.0]
  def change
    change_column_null :user_answers, :selected_answer, true
  end
end
