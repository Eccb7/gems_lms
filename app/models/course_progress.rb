class CourseProgress < ApplicationRecord
  # Associations
  belongs_to :user
  belongs_to :course

  # Validations
  validates :user, presence: true
  validates :course, presence: true
  validates :user_id, uniqueness: { scope: :course_id }
  validates :progress_percentage, numericality: {
    greater_than_or_equal_to: 0,
    less_than_or_equal_to: 100
  }, allow_nil: true

  # Scopes
  scope :completed, -> { where(completed: true) }
  scope :in_progress, -> { where(completed: false, progress_percentage: 1..) }
  scope :not_started, -> { where(progress_percentage: [ nil, 0 ]) }
  scope :recent, -> { order(last_accessed_at: :desc) }

  # Callbacks
  before_save :set_completed_at
  after_update :update_enrollment_status

  # Instance methods
  def completion_status
    return "Not Started" if progress_percentage.nil? || progress_percentage.zero?
    return "Completed" if completed?
    "In Progress"
  end

  def complete!
    update!(
      completed: true,
      progress_percentage: 100,
      completed_at: Time.current
    )
  end

  def reset_progress!
    update!(
      completed: false,
      progress_percentage: 0,
      completed_at: nil,
      last_accessed_at: Time.current
    )
  end

  def next_lesson
    course.next_lesson_for(user)
  end

  def completed_lessons_count
    user.lesson_progresses.joins(:lesson)
        .where(lessons: { section: course.sections }, completed: true)
        .count
  end

  def total_lessons_count
    course.lessons.count
  end

  def estimated_time_remaining
    return 0 if completed?

    total_duration = course.total_duration
    return total_duration unless progress_percentage&.positive?

    remaining_percentage = 100 - progress_percentage
    (total_duration * remaining_percentage / 100).round
  end

  def touch_last_accessed!
    update_column(:last_accessed_at, Time.current)
  end

  private

  def set_completed_at
    if completed_changed? && completed?
      self.completed_at = Time.current
      self.progress_percentage = 100
    elsif completed_changed? && !completed?
      self.completed_at = nil
    end
  end

  def update_enrollment_status
    return unless completed_changed? && completed?

    enrollment = user.enrollments.find_by(course: course)
    enrollment&.complete!
  end
end
