class DiscussionReply < ApplicationRecord
  belongs_to :discussion
  belongs_to :user
  belongs_to :parent_reply, class_name: 'DiscussionReply', optional: true

  has_many :child_replies, class_name: 'DiscussionReply', foreign_key: 'parent_reply_id', dependent: :destroy
  has_many :discussion_votes, as: :votable, dependent: :destroy

  validates :content, presence: true, length: { minimum: 5 }

  scope :root_replies, -> { where(parent_reply_id: nil) }
  scope :recent, -> { order(created_at: :desc) }

  def vote_score
    discussion_votes.sum(:value)
  end

  def is_solution?
    discussion.solution_reply_id == id
  end

  def mark_as_solution!
    discussion.update!(solution_reply_id: id, answered: true)
  end
end
