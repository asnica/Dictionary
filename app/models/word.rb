class Word < ApplicationRecord
    validates :japanese, presence: true, uniqueness: true
    validates :english, presence: true

    has_many :word_taggings, dependent: :destroy
    has_many :word_tags, through: :word_taggings

    has_many :user_words, dependent: :destroy
    has_many :users, through: :user_words

    has_many :synonyms, dependent: :destroy

    accepts_nested_attributes_for :synonyms, allow_destroy: true, reject_if: :all_blank

    def tag_names
      word_tags.pluck(:name)
    end

    def has_tag?(tag_name)
       word_tags.exists?(name: tag_name)
    end
end
