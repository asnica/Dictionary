class AddActiveToWords < ActiveRecord::Migration[8.0]
  def change
    add_column :words, :active, :boolean, default: true, null: false
  end
end
