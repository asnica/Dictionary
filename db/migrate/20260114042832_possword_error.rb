class PosswordError < ActiveRecord::Migration[8.0]
  def change
    rename_column :users, :possword_digest, :password_digest
  end
end
