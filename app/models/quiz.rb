class Quiz < ApplicationRecord
  belongs_to :user

  has_many :quiz_questions, dependent: :destroy
  has_many :words, through: :quiz_questions

  enum :status, [ :not_started, :in_progress, :completed ], default: :not_started

  validates :total_questions, presence: true, numericality: { only_integer: true, greater_than: 0 }

  validates :current_questions_number, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }


  scope :recently_completed, -> { where(status: "completed").order(completed_at: :desc) }
  scope :in_progress_for_user, ->(user_id) { where(user_id: user_id, status: "in_progress") }

  def generate_questions!
    random_words = Word.order("RANDOM()").limit(10)

    random_words.each do |word|
      correct_answer = word.english
      wrong_answers = Word.where.not(id: word.id).order("RANDOM()").limit(2).pluck(:english)
      choices = ([ correct_answer ] + wrong_answers).shuffle

      quiz_questions.create!(
        word: word,
        choices: choices
      )
    end
    update!(status: "in_progress", started_at: Time.current)
  end

  def current_question
    quiz_questions.offset(current_questions_number).first
  end

  def move_to_next_question!
    if current_questions_number < total_questions - 1
      increment!(:current_questions_number)
    end
  end

  def move_to_previous_question!
    if current_questions_number > 0
      decrement!(:current_questions_number)
    end
  end


  def grade!
    correct_count = quiz_questions.where(is_correct: true).count
    update!(
      score: correct_count,
      status: "completed",
      completed_at: Time.current
    )
  end



  def accuracy_rate
    return 0 if score.nil? || total_questions.zero?
    (score.to_f / total_questions * 100).round(2)
  end

  def last_question?
    current_questions_number >= total_questions - 1
  end

  def first_question?
    current_questions_number.zero?
  end
end
