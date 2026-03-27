class AddConstraintToUsers < ActiveRecord::Migration[8.0]
  def change
    add_check_constraint :users, "image_credits >= 0", name: "image_credits_non_negative"
  end
end
