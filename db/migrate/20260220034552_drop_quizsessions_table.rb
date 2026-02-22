class DropQuizsessionsTable < ActiveRecord::Migration[8.0]
  def change
    drop_table :quizsessions
  end
end
