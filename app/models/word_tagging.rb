class WordTagging < ApplicationRecord
  belongs_to :word
  belongs_to :word_tag
end
