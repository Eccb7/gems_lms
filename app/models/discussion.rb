class Discussion < ApplicationRecord
  belongs_to :course
  belongs_to :user
  belongs_to :lesson, optional: true

  has_many :discussion_replies, dependent: :destroy
  has_many :discussion_votes, dependent: :destroy

  validates :title, presence: true, length: { minimum: 5, maximum: 200 }
  validates :content, presence: true, length: { minimum: 10 }

  scope :recent, -> { order(created_at: :desc) }
  scope :popular, -> { joins(:discussion_votes).group(:id).order('COUNT(discussion_votes.id) DESC') }
  scope :answered, -> { where(answered: true) }
  scope :unanswered, -> { where(answered: false) }

  enum status: { active: 0, locked: 1, archived: 2 }

  def mark_as_answered!
    update!(answered: true)
  end

  def vote_score
    discussion_votes.sum(:value)
  end

  def reply_count
    discussion_replies.count
  end
end
