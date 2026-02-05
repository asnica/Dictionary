class User < ApplicationRecord
    has_secure_password

    has_many :user_words, dependent: :destroy
    has_many :words, through: :user_words
    has_many :quizzes, dependent: :destroy


    validates :name, presence: true, length: { maximum: 50 }
    validates :password, presence: true, length: { minimum: 6 }
    validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }


    has_many :word_tags, dependent: :destroy
    before_save :downcase_email
    before_create :generate_confirmation_token

    def current_quiz
      quizzes.find_by(status: "in_progress")
    end

    def has_quiz_in_progress?
      current_quiz.present?
    end

    def completed_quizzes
      quizzes.completed.order(completed_at: :desc)
    end

    def average_score
       completed = quizzes.completed
       return 0 if completed.empty?
       completed.average(:score).to_f.round(2)
    end

    def confirm_email
      update(confirmed_at: Time.current, confirmation_token: nil)
    end

    def confirmed?
      confirmed_at.present?
    end

    private

    def downcase_email
        self.email = email.downcase
    end

    def generate_confirmation_token
      self.confirmation_token = SecureRandom.urlsafe_base64.to_s
    end
end
