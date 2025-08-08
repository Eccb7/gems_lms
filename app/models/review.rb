class Review < ApplicationRecord
  belongs_to :user
  belongs_to :course

  validates :rating, presence: true, inclusion: { in: 1..5 }
  validates :content, presence: true, length: { minimum: 10, maximum: 1000 }
  validates :user_id, uniqueness: { scope: :course_id, message: "can only review a course once" }

  scope :recent, -> { order(created_at: :desc) }
  scope :by_rating, ->(rating) { where(rating: rating) }
  scope :approved, -> { where(approved: true) }

  before_create :set_defaults

  def helpful_votes_count
    helpful_votes.count
  end

  private

  def set_defaults
    self.approved = true # Auto-approve reviews, or implement moderation
  end
end
