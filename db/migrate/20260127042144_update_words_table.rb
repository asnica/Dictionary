class UpdateWordsTable < ActiveRecord::Migration[8.0]
  def change
    change_column_null :words, :japanese, false
    change_column_null :words, :english, false
  end
end
