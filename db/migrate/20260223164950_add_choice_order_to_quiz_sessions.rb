class AddChoiceOrderToQuizSessions < ActiveRecord::Migration[8.0]
  def change
    add_column :quiz_sessions, :choice_order, :json, default: {}
  end
end
