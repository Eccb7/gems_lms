class Lesson < ApplicationRecord
  # Enums
  enum :lesson_type, { video: 0, text: 1, quiz: 2, assignment: 3, live_session: 4 }

  # Associations
  belongs_to :section
  has_one :course, through: :section
  has_many :lesson_progresses, dependent: :destroy
  has_many :students_completed, through: :lesson_progresses, source: :user
  has_one :quiz, dependent: :destroy
  has_many :assignments, dependent: :destroy

  # Active Storage attachments
  has_one_attached :video_file
  has_many_attached :materials

  # Action Text
  has_rich_text :content

  # Validations
  validates :title, presence: true, length: { minimum: 3, maximum: 100 }
  validates :section, presence: true
  validates :position, presence: true, uniqueness: { scope: :section_id }
  validates :lesson_type, presence: true
  validates :duration_minutes, presence: true, numericality: { greater_than: 0 }
  validate :video_file_format, if: :video?

  # Scopes
  scope :ordered, -> { order(:position) }
  scope :by_type, ->(type) { where(lesson_type: type) }

  # Callbacks
  before_validation :set_position, on: :create
  before_validation :set_default_duration, on: :create

  # Instance methods
  def completed_by?(user)
    lesson_progresses.exists?(user: user, completed: true)
  end

  def progress_for(user)
    lesson_progresses.find_by(user: user)
  end

  def completion_rate
    return 0 if course.enrollment_count.zero?

    completed_count = lesson_progresses.where(completed: true).count
    (completed_count.to_f / course.enrollment_count * 100).round(2)
  end

  def next_lesson
    section.lessons.where("position > ?", position).first ||
    course.sections.where("position > ?", section.position).first&.lessons&.first
  end

  def previous_lesson
    section.lessons.where("position < ?", position).last ||
    course.sections.where("position < ?", section.position).last&.lessons&.last
  end

  def can_be_accessed_by?(user)
    # Check if user is enrolled in the course
    return false unless user.enrolled_in?(course)

    # For sequential access, check if previous lessons are completed
    # This can be configured per course later
    true
  end

  def move_to_position(new_position)
    transaction do
      if new_position > position
        section.lessons.where("position > ? AND position <= ?", position, new_position)
               .update_all("position = position - 1")
      else
        section.lessons.where("position >= ? AND position < ?", new_position, position)
               .update_all("position = position + 1")
      end

      update!(position: new_position)
    end
  end

  def mark_completed_by(user)
    progress = lesson_progresses.find_or_initialize_by(user: user)
    progress.update!(completed: true, completed_at: Time.current)

    # Update course progress
    update_course_progress_for(user)
  end

  private

  def set_position
    return if position.present?

    max_position = section.lessons.maximum(:position) || 0
    self.position = max_position + 1
  end

  def set_default_duration
    return if duration_minutes.present?

    case lesson_type
    when "video"
      self.duration_minutes = 10
    when "text"
      self.duration_minutes = 5
    when "quiz"
      self.duration_minutes = 15
    when "assignment"
      self.duration_minutes = 30
    else
      self.duration_minutes = 10
    end
  end

  def video_file_format
    return unless video_file.attached?

    unless video_file.content_type.in?([ "video/mp4", "video/avi", "video/mov", "video/wmv" ])
      errors.add(:video_file, "must be a valid video format (MP4, AVI, MOV, WMV)")
    end

    if video_file.byte_size > 500.megabytes
      errors.add(:video_file, "must be less than 500MB")
    end
  end

  def update_course_progress_for(user)
    course_progress = user.course_progresses.find_or_initialize_by(course: course)

    total_lessons = course.lessons.count
    completed_lessons = user.lesson_progresses.joins(:lesson)
                           .where(lessons: { section: course.sections }, completed: true)
                           .count

    progress_percentage = total_lessons.zero? ? 0 : (completed_lessons.to_f / total_lessons * 100).round(2)

    course_progress.update!(
      progress_percentage: progress_percentage,
      completed: progress_percentage >= 100,
      completed_at: progress_percentage >= 100 ? Time.current : nil,
      last_accessed_at: Time.current
    )
  end
end
