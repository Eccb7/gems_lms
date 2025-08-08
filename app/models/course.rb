class Course < ApplicationRecord
  include PgSearch::Model

  # Enums
  enum :status, { draft: 0, pending_approval: 1, published: 2, archived: 3 }
  enum :difficulty_level, { beginner: 0, intermediate: 1, advanced: 2, expert: 3 }

  # Associations
  belongs_to :instructor, class_name: "User"
  belongs_to :category
  has_many :sections, -> { order(:position) }, dependent: :destroy
  has_many :lessons, through: :sections
  has_many :enrollments, dependent: :destroy
  has_many :students, through: :enrollments, source: :user
  has_many :course_progresses, dependent: :destroy
  has_many :quizzes, through: :lessons
  has_many :assignments, through: :lessons

  # Active Storage attachments
  has_one_attached :cover_image
  has_one_attached :promotional_video

  # Search configuration
  pg_search_scope :search_by_title_and_description,
                  against: [ :title, :description, :objectives ],
                  using: {
                    tsearch: { prefix: true }
                  }

  # Validations
  validates :title, presence: true, length: { minimum: 3, maximum: 100 }
  validates :description, presence: true, length: { minimum: 10 }
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :instructor, presence: true
  validates :category, presence: true
  validates :status, presence: true
  validates :difficulty_level, presence: true
  validate :instructor_can_create_courses
  validate :cover_image_format
  validate :promotional_video_format

  # Scopes
  scope :published_courses, -> { where(status: :published) }
  scope :featured_courses, -> { where(featured: true) }
  scope :featured, -> { where(featured: true) }
  scope :by_category, ->(category) { where(category: category) }
  scope :by_difficulty, ->(difficulty) { where(difficulty_level: difficulty) }
  scope :by_instructor, ->(instructor) { where(instructor: instructor) }
  scope :recent, -> { order(created_at: :desc) }
  scope :popular, -> { left_joins(:enrollments).group(:id).order("COUNT(enrollments.id) DESC") }

  # Callbacks
  before_save :set_published_at
  after_create :create_default_section

  # Instance methods
  def total_duration
    lessons.sum(:duration_minutes)
  end

  def total_lessons
    lessons.count
  end

  def enrollment_count
    enrollments.count
  end

  def average_rating
    # TODO: Implement when rating system is added
    0.0
  end

  def completion_rate
    return 0 if enrollments.count.zero?

    completed_enrollments = course_progresses.where(completed: true).count
    (completed_enrollments.to_f / enrollments.count * 100).round(2)
  end

  def can_be_enrolled_by?(user)
    published? && !user.enrolled_in?(self)
  end

  def next_lesson_for(user)
    user_progress = user.course_progress(self)
    return lessons.first unless user_progress

    completed_lesson_ids = user.lesson_progresses.where(lesson: lessons, completed: true).pluck(:lesson_id)
    lessons.where.not(id: completed_lesson_ids).first
  end

  def progress_for(user)
    user.course_progress(self)&.progress_percentage || 0
  end

  def is_free?
    price.zero?
  end

  def publish!
    update!(status: :published, published_at: Time.current)
  end

  def archive!
    update!(status: :archived)
  end

  private

  def instructor_can_create_courses
    return unless instructor

    unless instructor.can_create_courses?
      errors.add(:instructor, "must be an instructor or admin to create courses")
    end
  end

  def set_published_at
    if status_changed? && published?
      self.published_at = Time.current unless published_at
    end
  end

  def create_default_section
    sections.create!(title: "Introduction", position: 1)
  end

  def cover_image_format
    return unless cover_image.attached?

    unless cover_image.content_type.in?([ "image/jpeg", "image/png", "image/gif" ])
      errors.add(:cover_image, "must be a JPEG, PNG, or GIF image")
    end

    if cover_image.byte_size > 5.megabytes
      errors.add(:cover_image, "must be less than 5MB")
    end
  end

  def promotional_video_format
    return unless promotional_video.attached?

    unless promotional_video.content_type.in?([ "video/mp4", "video/avi", "video/mov" ])
      errors.add(:promotional_video, "must be a MP4, AVI, or MOV video")
    end

    if promotional_video.byte_size > 100.megabytes
      errors.add(:promotional_video, "must be less than 100MB")
    end
  end
end
