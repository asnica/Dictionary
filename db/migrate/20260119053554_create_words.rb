class CreateWords < ActiveRecord::Migration[8.0]
  def change
    create_table :words do |t|
      t.string :japanese, null: false
      t.string :reading
      t.string :english, null: false

      t.timestamps
    end

    add_index :words, :japanese, unique: true
    
  end
end
