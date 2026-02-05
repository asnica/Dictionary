class QuizQuestion < ApplicationRecord
  belongs_to :quiz
  belongs_to :word

  validates :choices, presence: true
  validate :choices_must_be_array_of_three

  def submit_answer!(answer)
    update!(
      user_answer: answer,
      is_correct: answer == word.english
    )
  end




  def correct_answer
    word.english
  end

  def question_number
    quiz.quiz_questions.order(:id).index(self) + 1
  end

  private
  def choices_must_be_array_of_three
    unless choices.is_a?(Array)&&choices.size == 3
      errors.add(:choices, "選択肢は三個になるべきです")
    end
  end
end
