class Enrollment < ApplicationRecord
  # Enums
  enum :status, { active: 0, completed: 1, dropped: 2, suspended: 3 }

  # Associations
  belongs_to :user
  belongs_to :course

  # Validations
  validates :user, presence: true
  validates :course, presence: true
  validates :user_id, uniqueness: { scope: :course_id, message: "is already enrolled in this course" }
  validates :enrolled_at, presence: true
  validate :user_can_enroll

  # Scopes
  scope :recent, -> { order(enrolled_at: :desc) }
  scope :by_status, ->(status) { where(status: status) }
  scope :completed_enrollments, -> { where(status: :completed) }

  # Callbacks
  before_validation :set_enrolled_at, on: :create
  after_create :create_course_progress
  after_update :update_completion_status

  # Instance methods
  def progress_percentage
    course_progress = user.course_progress(course)
    course_progress&.progress_percentage || 0
  end

  def completed?
    status == "completed" || completed_at.present?
  end

  def duration_enrolled
    end_time = completed_at || Time.current
    ((end_time - enrolled_at) / 1.day).round
  end

  def complete!
    update!(
      status: :completed,
      completed_at: Time.current,
      progress_percentage: 100
    )
  end

  def drop!
    update!(status: :dropped)
  end

  def suspend!
    update!(status: :suspended)
  end

  def reactivate!
    update!(status: :active)
  end

  private

  def set_enrolled_at
    self.enrolled_at ||= Time.current
  end

  def user_can_enroll
    return unless user && course

    unless user.student? || user.admin?
      errors.add(:user, "must be a student or admin to enroll in courses")
    end

    unless course.can_be_enrolled_by?(user)
      errors.add(:course, "is not available for enrollment")
    end
  end

  def create_course_progress
    user.course_progresses.find_or_create_by(course: course) do |progress|
      progress.progress_percentage = 0
      progress.completed = false
      progress.last_accessed_at = Time.current
    end
  end

  def update_completion_status
    if status_changed? && completed?
      course_progress = user.course_progress(course)
      course_progress&.update!(completed: true, completed_at: Time.current)
    end
  end
end
