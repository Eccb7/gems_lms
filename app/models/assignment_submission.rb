class AssignmentSubmission < ApplicationRecord
  # Enums
  enum :status, { draft: 0, submitted: 1, graded: 2, returned: 3 }

  # Associations
  belongs_to :user
  belongs_to :assignment
  has_one :course, through: :assignment

  # Active Storage attachments
  has_many_attached :files

  # Action Text
  has_rich_text :content
  has_rich_text :feedback

  # Validations
  validates :user, presence: true
  validates :assignment, presence: true
  validates :user_id, uniqueness: { scope: :assignment_id }
  validate :content_or_files_present, if: :submitted?
  validate :user_can_submit
  validate :file_formats_valid

  # Scopes
  scope :submitted_submissions, -> { where(status: [ :submitted, :graded, :returned ]) }
  scope :pending_grading, -> { where(status: :submitted) }
  scope :graded_submissions, -> { where(status: [ :graded, :returned ]) }
  scope :recent, -> { order(submitted_at: :desc) }

  # Callbacks
  before_save :set_submitted_at, if: :will_save_change_to_status?

  # Instance methods
  def submit!
    return false unless can_be_submitted?

    transaction do
      update!(
        status: :submitted,
        submitted_at: Time.current
      )

      # Create notification for instructor
      create_submission_notification
    end
  end

  def grade!(grade_value, feedback_text = nil)
    transaction do
      update!(
        status: :graded,
        grade: grade_value,
        feedback: feedback_text
      )

      # Create notification for student
      create_grading_notification

      # Update lesson progress if assignment is passed
      if passed?
        assignment.lesson.mark_completed_by(user)
      end
    end
  end

  def return_for_revision!(feedback_text)
    update!(
      status: :returned,
      feedback: feedback_text
    )

    create_return_notification
  end

  def can_be_submitted?
    return false unless draft?
    return false if assignment.is_overdue? && !assignment.late_submission_allowed?

    has_required_content?
  end

  def is_late?
    return false unless submitted_at && assignment.has_due_date?

    submitted_at > assignment.due_date
  end

  def days_late
    return 0 unless is_late?

    ((submitted_at - assignment.due_date) / 1.day).ceil
  end

  def percentage_grade
    return 0 unless grade && assignment.max_points&.positive?

    (grade / assignment.max_points * 100).round(2)
  end

  def passed?
    return false unless grade

    # Assuming 60% is passing grade - this can be configurable
    percentage_grade >= 60
  end

  def letter_grade
    return nil unless grade

    percentage = percentage_grade
    case percentage
    when 90..100 then "A"
    when 80...90 then "B"
    when 70...80 then "C"
    when 60...70 then "D"
    else "F"
    end
  end

  def time_spent_days
    return 0 unless submitted_at

    start_time = created_at
    ((submitted_at - start_time) / 1.day).round
  end

  private

  def set_submitted_at
    if status_changed? && submitted?
      self.submitted_at = Time.current
    elsif status_changed? && draft?
      self.submitted_at = nil
    end
  end

  def content_or_files_present
    return if content.present? || files.attached?

    errors.add(:base, "Must provide either written content or file uploads")
  end

  def user_can_submit
    return unless user && assignment

    unless user.enrolled_in?(assignment.course)
      errors.add(:user, "must be enrolled in the course to submit assignments")
    end
  end

  def file_formats_valid
    return unless files.attached?

    files.each do |file|
      unless file.content_type.in?([ "application/pdf", "application/msword",
                                   "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
                                   "text/plain", "image/jpeg", "image/png" ])
        errors.add(:files, "#{file.filename} is not a supported file format")
      end

      if file.byte_size > 10.megabytes
        errors.add(:files, "#{file.filename} must be less than 10MB")
      end
    end
  end

  def has_required_content?
    case assignment.submission_format
    when "text"
      content.present?
    when "file_upload"
      files.attached?
    when "url"
      content.present? # URL would be in content field
    when "both"
      content.present? || files.attached?
    else
      false
    end
  end

  def create_submission_notification
    NotificationService.create_for_instructor(
      assignment.course.instructor,
      "New Assignment Submission",
      "#{user.display_name} has submitted assignment: #{assignment.title}",
      :assignment_submitted
    )
  end

  def create_grading_notification
    NotificationService.create_for_user(
      user,
      "Assignment Graded",
      "Your assignment '#{assignment.title}' has been graded. Grade: #{grade}/#{assignment.max_points}",
      :assignment_graded
    )
  end

  def create_return_notification
    NotificationService.create_for_user(
      user,
      "Assignment Returned",
      "Your assignment '#{assignment.title}' has been returned for revision.",
      :assignment_returned
    )
  end
end
