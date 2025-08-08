class Assignment < ApplicationRecord
  # Enums
  enum :submission_format, { text: 0, file_upload: 1, url: 2, both: 3 }

  # Associations
  belongs_to :lesson
  has_one :course, through: :lesson
  has_many :assignment_submissions, dependent: :destroy

  # Validations
  validates :title, presence: true, length: { minimum: 3, maximum: 100 }
  validates :description, presence: true, length: { minimum: 10 }
  validates :lesson, presence: true
  validates :max_points, numericality: { greater_than: 0 }
  validates :submission_format, presence: true

  # Action Text
  has_rich_text :description

  # Scopes
  scope :with_due_dates, -> { where.not(due_date: nil) }
  scope :overdue, -> { where("due_date < ?", Time.current) }
  scope :upcoming, -> { where("due_date > ?", Time.current) }

  # Instance methods
  def has_due_date?
    due_date.present?
  end

  def is_overdue?
    has_due_date? && due_date < Time.current
  end

  def days_until_due
    return nil unless has_due_date?

    ((due_date - Time.current) / 1.day).ceil
  end

  def submission_for_user(user)
    assignment_submissions.find_by(user: user)
  end

  def submitted_by?(user)
    submission_for_user(user)&.submitted?
  end

  def graded_for?(user)
    submission_for_user(user)&.graded?
  end

  def submission_count
    assignment_submissions.where(status: :submitted).count
  end

  def graded_submission_count
    assignment_submissions.where(status: :graded).count
  end

  def average_grade
    graded_submissions = assignment_submissions.where(status: :graded).where.not(grade: nil)
    return 0 if graded_submissions.empty?

    graded_submissions.average(:grade).to_f.round(2)
  end

  def completion_rate
    total_enrollments = course.enrollment_count
    return 0 if total_enrollments.zero?

    submitted_count = assignment_submissions.where(status: [ :submitted, :graded ]).count
    (submitted_count.to_f / total_enrollments * 100).round(2)
  end

  def can_be_submitted_by?(user)
    return false unless user.enrolled_in?(course)
    return false if is_overdue?

    !submitted_by?(user)
  end

  def late_submission_allowed?
    # Can be configured later - for now, allow late submissions
    true
  end

  private

  def set_defaults
    self.max_points ||= 100.0
    self.submission_format ||= :text
  end
end
