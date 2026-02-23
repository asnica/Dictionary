class QuizSession < ApplicationRecord
  belongs_to :user
  has_many :user_answers, dependent: :destroy
  validate :word_should_be_over_10, on: :create

  QUESTION_COUNT = 10

  scope :in_progress, ->(user) { where(user: user, status: "in_progress").order(recently_worked: :desc) }
  scope :completed, ->(user) { where(user: user, status: "completed").order(recently_worked: :desc) }



  def self.retry_from!(user, previous_session)
    new_session = create!(
      user: user,
      word_order: previous_session.word_order,
      choice_order: previous_session.choice_order,
      current_index: 0,
      status: "in_progress",
      score: 0,
      recently_worked: Time.current
    )
   previous_session.destroy
   new_session
  end

  def self.start_new!(user)
    word_ids = Word.pluck(:id).sample(QUESTION_COUNT)

    choices = word_ids.each_with_object({}) do |id, hash|
      word = Word.find(id)
      hash[id] = word.choices_for_quiz
    end

    create!(
      user: user,
      word_order: word_ids,
      choice_order: choices,
      current_index: 0,
      status: "in_progress",
      score: 0,
      recently_worked: Time.current
    )
  end

  def current_word
    Word.find(word_order[current_index])
  end


  def finished?
    current_index>= word_order.size
  end

  def complete!
    update!(
      status: "completed",
      score: user_answers.where(is_correct: true).count,
      recently_worked: Time.current
    )
  end



  def next!
    update!(
      current_index: current_index + 1,
      recently_worked: Time.current,


    )
  end

  def current_choices
    choice_order[word_order[current_index].to_s]
  end

  def previous!
    return if current_index.zero?
    update!(current_index: current_index - 1, recently_worked: Time.current)
  end

  def word_should_be_over_10
  if Word.count < QUESTION_COUNT
    errors.add(:base, "単語が#{QUESTION_COUNT}個以上必要です。現在の単語数: #{Word.count}")
  end
end
end
