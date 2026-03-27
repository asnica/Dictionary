class User < ApplicationRecord
    has_secure_password

    has_many :user_words, dependent: :destroy
    has_many :words, through: :user_words
    has_many :quiz_sessions, dependent: :destroy

    validates :name, presence: true, length: { maximum: 50 }
    validates :password, presence: true, length: { minimum: 6 }
    validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }


    has_many :word_tags, dependent: :destroy

    has_many :invitations, foreign_key: :inviter_id, dependent: :destroy

    before_save :downcase_email








    def has_quiz_in_progress?
      current_quiz.present?
    end


    def can_generate_image?
      image_credits > 0
    end

    def consume_credit!
      raise "クレジット不足" unless can_generate_image?
      decrement!(:image_credits)
    end

    def accepted_invitation_count
      invitations.accepted.count
    end

    private

    def downcase_email
        self.email = email.downcase
    end
end
