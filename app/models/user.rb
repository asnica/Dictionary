class User < ApplicationRecord

    has_secure_password

    has_many :user_words, dependent: :destroy
    has_many :words, through: :user_words


    validates :name, presence: true, length: {maximum: 50}
    validates :password, presence: true, length: {minimum: 6}
    validates :email, presence: true, uniqueness: true, format: {with: URI::MailTo::EMAIL_REGEXP}
   

    has_many :word_tags, dependent: :destroy
    before_save :downcase_email

    private 

    def downcase_email
        self.email = email.downcase
    end
    



end
