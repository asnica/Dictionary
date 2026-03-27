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


    scope :active, -> { where(active: true) }



    attr_accessor :ai_image_url, :remove_image
    before_validation :attach_image_from_url, if: -> { ai_image_url.present? }
    before_validation :purge_image, if: -> { ActiveModel::Type::Boolean.new.cast(remove_image) }



    def tag_names
      word_tags.pluck(:name)
    end

    def has_tag?(tag_name)
       word_tags.exists?(name: tag_name)
    end

    def creator_name
      users.first&.name || "不明"
    end






    def choices_for_quiz
      distractors = Word.active.where.not(id: self.id).pluck(:reading).sample(2)
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

   def attach_image_from_url
    return if ai_image_url.blank?
    return if image.attached?

    resp = Faraday.get(ai_image_url)
    unless resp.success?
      errors.add(:base, "画像のダウンロードに失敗しました。")
      return
    end

    image.attach(
      io: StringIO.new(resp.body),
      filename: "ai_#{Time.current.strftime("%Y%m%d%H%M%S")}.jpg",
      content_type: "image/jpeg"
    )

  rescue StandardError => e
    Rails.logger.error("[Word#attach_image_from_url]#{e.class}:#{e.message}")
    errors.add(:base, "画像の添付に失敗しました。")
  end

  def purge_image
    image.purge if image.attached?
  end
end
