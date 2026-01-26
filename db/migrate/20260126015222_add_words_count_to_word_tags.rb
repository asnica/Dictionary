class AddWordsCountToWordTags < ActiveRecord::Migration[8.0]
  def change
    add_column :word_tags, :words_count, :integer, default: 0, null: false

    reversible do |dir|
       dir.up do
          WordTag.find_each do |tag|
            WordTag.reset_counters(tag.id, :words)
          end
        end
      end
    end
  end
end
