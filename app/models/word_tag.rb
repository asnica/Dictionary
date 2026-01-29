class WordTag < ApplicationRecord
  belongs_to :user, optional: true
  has_many :word_taggings, dependent: :destroy
  has_many :words, through: :word_taggings

  validates :name, presence: true, length: { maximum: 50 }
  validates :name, uniqueness: true, if: :system_tag?
  validates :name, uniqueness: { scope: :user_id }, if: :custom_tag?

  scope :system_tags, -> { where(user_id: nil) }
  scope :custom_tags, -> { where.not(user_id: nil) }

  scope :for_user, ->(user) {
    where(user_id: [ nil, user.id ]).order(:category, :name)}


  def system_tag?
    user_id.nil?
  end

  def custom_tag?
    user_id.present?
  end
end
