class Word < ApplicationRecord

    validates :japanese, presence: true, uniqueness: true
    validates :english, presence: true
end
