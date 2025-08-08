class Activity < ApplicationRecord
  belongs_to :user

  validates :description, presence: true
  validates :activity_type, presence: true

  enum activity_type: {
    lesson_completed: 0,
    course_enrolled: 1,
    assignment_submitted: 2,
    quiz_completed: 3,
    achievement_earned: 4,
    course_completed: 5
  }

  scope :recent, -> { order(created_at: :desc) }

  def icon
    case activity_type
    when 'lesson_completed'
      '✅'
    when 'course_enrolled'
      '📚'
    when 'assignment_submitted'
      '📝'
    when 'quiz_completed'
      '🧠'
    when 'achievement_earned'
      '🏆'
    when 'course_completed'
      '🎓'
    else
      '📈'
    end
  end
end
