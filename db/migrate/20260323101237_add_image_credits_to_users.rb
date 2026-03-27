class AddImageCreditsToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :image_credits, :integer, default: 3, null: false
  end
end
