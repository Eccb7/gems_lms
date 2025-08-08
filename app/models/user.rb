class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Enums for roles
  enum :role, { student: 0, instructor: 1, admin: 2 }

  # Active Storage attachments
  has_one_attached :avatar

  # Associations
  has_many :enrollments, dependent: :destroy
  has_many :enrolled_courses, through: :enrollments, source: :course
  has_many :created_courses, class_name: "Course", foreign_key: "instructor_id", dependent: :destroy
  has_many :quiz_attempts, dependent: :destroy
  has_many :assignment_submissions, dependent: :destroy
  has_many :notifications, dependent: :destroy
  has_many :course_progresses, dependent: :destroy
  has_many :lesson_progresses, dependent: :destroy

  # Validations
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :role, presence: true
  validates :phone, format: { with: /\A[\+]?[1-9][\d]{0,15}\z/, message: "Invalid phone number format" }, allow_blank: true
  validates :date_of_birth, presence: true, if: :student?
  validate :avatar_format

  # Callbacks
  before_validation :set_default_role, on: :create

  # Scopes
  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }
  scope :by_role, ->(role) { where(role: role) }

  # Instance methods
  def full_name
    "#{first_name} #{last_name}"
  end

  def display_name
    full_name.present? ? full_name : email
  end

  def age
    return nil unless date_of_birth

    ((Time.zone.now - date_of_birth.to_time) / 1.year.seconds).floor
  end

  def can_create_courses?
    instructor? || admin?
  end

  def enrolled_in?(course)
    enrolled_courses.include?(course)
  end

  def course_progress(course)
    course_progresses.find_by(course: course)
  end

  def completed_courses
    enrolled_courses.joins(:course_progresses)
                   .where(course_progresses: { user: self, completed: true })
  end

  def deactivate!
    update!(active: false)
  end

  def activate!
    update!(active: true)
  end

  private

  def set_default_role
    self.role ||= :student
  end

  def avatar_format
    return unless avatar.attached?

    unless avatar.content_type.in?([ "image/jpeg", "image/png", "image/gif" ])
      errors.add(:avatar, "must be a JPEG, PNG, or GIF image")
    end

    if avatar.byte_size > 5.megabytes
      errors.add(:avatar, "must be less than 5MB")
    end
  end
end
