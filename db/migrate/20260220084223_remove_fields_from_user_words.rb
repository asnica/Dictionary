class RemoveFieldsFromUserWords < ActiveRecord::Migration[8.0]
  def change
    remove_column :user_words, :memorized, :boolean
    remove_column :user_words, :quiz_count, :integer
    remove_column :user_words, :correct_count, :integer
    remove_column :user_words, :last_studied_at, :datetime
  end
end
