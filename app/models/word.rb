class Word < ApplicationRecord
    validates :japanese, presence: true, uniqueness: { case_sensitive: true }
    validates :english, presence: true

    has_many :word_taggings, dependent: :destroy
    has_many :word_tags, through: :word_taggings

    has_many :user_words, dependent: :destroy
    has_many :users, through: :user_words

    has_many :synonyms, dependent: :destroy

    has_many :quiz_questions, dependent: :restrict_with_error
    has_many :quizzes, through: :quiz_questions

    has_one_attached :image
    validate :acceptable_image

    accepts_nested_attributes_for :synonyms, allow_destroy: true, reject_if: :all_blank

    def tag_names
      word_tags.pluck(:name)
    end

    def has_tag?(tag_name)
       word_tags.exists?(name: tag_name)
    end


    def used_in_quiz?
      quiz_questions.exists?
    end

    def quiz_count
      quiz_questions.joins(:quiz).where(quizzes: { status: "completed" }).count
    end

    def correct_rate
      total = quiz_questions.where.not(is_correct: nil).count
      return 0 if total.zero?
      correct = quiz_questions.where(is_correct: true).count
      (correct.to_f / total * 100).round(2)
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
end
