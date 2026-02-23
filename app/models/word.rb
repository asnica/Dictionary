class Word < ApplicationRecord
    validates :japanese, presence: true, uniqueness: { case_sensitive: true }
    validates :english, presence: true

    has_many :word_taggings, dependent: :destroy
    has_many :word_tags, through: :word_taggings

    has_many :user_words, dependent: :destroy
    has_many :users, through: :user_words
    has_many :user_answers, dependent: :destroy

    has_many :synonyms, dependent: :destroy


    has_one_attached :image
    validate :acceptable_image

    accepts_nested_attributes_for :synonyms, allow_destroy: true, reject_if: :all_blank
    attr_accessor :remove_image
    before_save :purge_image_if_requested

    def tag_names
      word_tags.pluck(:name)
    end

    def has_tag?(tag_name)
       word_tags.exists?(name: tag_name)
    end


      def choices_for_quiz
        distractors = Word.where.not(id: self.id).pluck(:reading).sample(2)
        (distractors + [ self.reading ]).shuffle
      end



    private
    def acceptable_image
      return unless image.attached?

      if image.byte_size > 5.megabytes
        errors.add(:image, "は5MB以下にしてください。")
      end
      acceptable_types = [ "image/jpeg", "image/png", "image/gif" ]
      unless acceptable_types.include?(image.content_type)
        errors.add(:image, "はJPEG、PNG、GIF形式にしてください。")
      end
    end

    def purge_image_if_requested
      image.purge if remove_image == "1" && image.attached?
    end
end
