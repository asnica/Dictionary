class UserWord < ApplicationRecord
  belongs_to :user
  belongs_to :word

  validates :word_id, uniqueness: { scope: :user_id }
  validate :correct_counts_cannot_exceed_quiz_counts

  scope :memorized, -> {where(memorized: true)}
  scope :recently_studied, -> {order(last_studied_at: :desc)}

  def accuracy
    return 0 if quiz_count.zero?
    (correct_count.to_f / quiz_count * 100).round(2)
  end
  private
  def correct_counts_cannot_exceed_quiz_counts
    return if correct_count.nil? || quiz_count.nil?
     if correct_count > quiz_count
      errors.add(:correct_count, "cannot exceed quiz count")
    end

  end



end
