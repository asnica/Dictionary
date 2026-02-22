class UserAnswer < ApplicationRecord
  belongs_to :quiz_session
  belongs_to :word
end
