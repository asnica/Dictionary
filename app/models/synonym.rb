class Synonym < ApplicationRecord
  belongs_to :word

  validates :synonym_word, presence: true, length: { maximum: 100 }

  validates :synonym_word, uniqueness: { scope: :word_id }
end
