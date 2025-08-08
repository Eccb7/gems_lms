class Notification < ApplicationRecord
  # Enums
  enum :notification_type, {
    general: 0,
    course_enrollment: 1,
    lesson_completed: 2,
    quiz_completed: 3,
    assignment_submitted: 4,
    assignment_graded: 5,
    assignment_returned: 6,
    course_completed: 7,
    announcement: 8,
    reminder: 9,
    system_alert: 10
  }

  # Associations
  belongs_to :user

  # Validations
  validates :user, presence: true
  validates :title, presence: true, length: { minimum: 3, maximum: 100 }
  validates :message, presence: true, length: { minimum: 5 }
  validates :notification_type, presence: true

  # Scopes
  scope :unread, -> { where(read: false) }
  scope :read_notifications, -> { where(read: true) }
  scope :recent, -> { order(sent_at: :desc) }
  scope :by_type, ->(type) { where(notification_type: type) }

  # Callbacks
  before_validation :set_sent_at, on: :create
  before_validation :set_read_status, on: :create

  # Instance methods
  def mark_as_read!
    update!(read: true)
  end

  def mark_as_unread!
    update!(read: false)
  end

  def age_in_days
    return 0 unless sent_at

    ((Time.current - sent_at) / 1.day).floor
  end

  def is_recent?
    age_in_days <= 7
  end

  def icon_class
    case notification_type
    when "course_enrollment"
      "fas fa-user-plus"
    when "lesson_completed"
      "fas fa-check-circle"
    when "quiz_completed"
      "fas fa-question-circle"
    when "assignment_submitted"
      "fas fa-file-upload"
    when "assignment_graded"
      "fas fa-star"
    when "assignment_returned"
      "fas fa-undo"
    when "course_completed"
      "fas fa-graduation-cap"
    when "announcement"
      "fas fa-bullhorn"
    when "reminder"
      "fas fa-bell"
    when "system_alert"
      "fas fa-exclamation-triangle"
    else
      "fas fa-info-circle"
    end
  end

  def priority_level
    case notification_type
    when "system_alert"
      "high"
    when "assignment_returned", "reminder"
      "medium"
    else
      "low"
    end
  end

  private

  def set_sent_at
    self.sent_at ||= Time.current
  end

  def set_read_status
    self.read = false if read.nil?
  end
end
