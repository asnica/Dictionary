class Invitation < ApplicationRecord
  REWARD_CREDITS = 3


  belongs_to :inviter, class_name: "User"

  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :email, uniqueness: { scope: :inviter_id, message: "にはすでに招待を送っています。" }
  validate :not_self_invite
  validate :not_existing_user


  before_create :generate_token


  scope :pending, -> { where(accepted_at: nil) }
  scope :accepted, -> { where.not(accepted_at: nil) }

  def accepted?
    accepted_at.present?
  end

  def accept!(new_user)
    return if accepted?

    transaction do
      update!(accepted_at: Time.current)

      inviter.with_lock do
        inviter.increment!(:image_credits, REWARD_CREDITS)
      end
    end
  end


  private

  def generate_token
    self.token = SecureRandom.urlsafe_base64(32)
  end

  def not_self_invite
    if inviter&.email&.downcase == email&.downcase
      errors.add(:email, "自分自身を招待することはできません。")
    end
  end


  def not_existing_user
    if User.exists?(email: email)
      errors.add(:email, "はすでに登録されています。")
    end
  end
end
