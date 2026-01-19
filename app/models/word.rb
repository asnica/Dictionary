class Word < ApplicationRecord

    validates :japanese, presence: true, uniqueness: true
    validates :english, presence: true

    has_many :user_words, dependent: :destroy
    has_many :users, through: :user_words
end
