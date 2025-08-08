class LessonProgress < ApplicationRecord
  # Associations
  belongs_to :user
  belongs_to :lesson

  # Validations
  validates :user, presence: true
  validates :lesson, presence: true
  validates :user_id, uniqueness: { scope: :lesson_id }
  validates :time_spent_seconds, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  # Scopes
  scope :completed, -> { where(completed: true) }
  scope :in_progress, -> { where(completed: false) }
  scope :recent, -> { order(updated_at: :desc) }

  # Callbacks
  before_save :set_completed_at
  after_update :update_course_progress

  # Instance methods
  def complete!
    update!(completed: true, completed_at: Time.current)
  end

  def time_spent_formatted
    return "0 minutes" unless time_spent_seconds&.positive?

    hours = time_spent_seconds / 3600
    minutes = (time_spent_seconds % 3600) / 60

    if hours > 0
      "#{hours}h #{minutes}m"
    else
      "#{minutes}m"
    end
  end

  def percentage_watched
    return 0 unless lesson.duration_minutes&.positive? && time_spent_seconds&.positive?

    lesson_duration_seconds = lesson.duration_minutes * 60
    percentage = (time_spent_seconds.to_f / lesson_duration_seconds * 100).round(2)
    [ percentage, 100 ].min
  end

  private

  def set_completed_at
    if completed_changed? && completed?
      self.completed_at = Time.current
    elsif completed_changed? && !completed?
      self.completed_at = nil
    end
  end

  def update_course_progress
    return unless completed_changed?

    course = lesson.course
    course_progress = user.course_progresses.find_or_initialize_by(course: course)

    total_lessons = course.lessons.count
    completed_lessons = user.lesson_progresses.joins(:lesson)
                           .where(lessons: { section: course.sections }, completed: true)
                           .count

    progress_percentage = total_lessons.zero? ? 0 : (completed_lessons.to_f / total_lessons * 100).round(2)

    course_progress.assign_attributes(
      progress_percentage: progress_percentage,
      completed: progress_percentage >= 100,
      completed_at: progress_percentage >= 100 ? Time.current : nil,
      last_accessed_at: Time.current
    )

    course_progress.save!
  end
end
