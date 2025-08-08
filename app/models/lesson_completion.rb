class LessonCompletion < ApplicationRecord
  belongs_to :user
  belongs_to :lesson

  validates :user_id, uniqueness: { scope: :lesson_id }

  scope :recent, -> { order(created_at: :desc) }
  scope :this_week, -> { where(created_at: 1.week.ago..Time.current) }
  scope :today, -> { where(created_at: Date.current.beginning_of_day..Date.current.end_of_day) }
end
