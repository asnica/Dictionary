class WordTagging < ApplicationRecord
  belongs_to :word
  belongs_to :word_tag, counter_cache: :words_count
end
