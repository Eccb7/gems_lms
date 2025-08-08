class Achievement < ApplicationRecord
  belongs_to :user

  validates :title, presence: true
  validates :description, presence: true
  validates :points, presence: true, numericality: { greater_than: 0 }

  scope :recent, -> { order(created_at: :desc) }

  def icon
    case achievement_type
    when 'first_course'
      '🎯'
    when 'course_completion'
      '🏆'
    when 'perfect_quiz'
      '🌟'
    when 'streak_week'
      '🔥'
    when 'streak_month'
      '💎'
    when 'assignment_ace'
      '📝'
    else
      '🏅'
    end
  end
end
