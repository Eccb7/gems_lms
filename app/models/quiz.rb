class Quiz < ApplicationRecord
  # Associations
  belongs_to :lesson
  has_one :course, through: :lesson
  has_many :quiz_questions, -> { order(:position) }, dependent: :destroy
  has_many :quiz_attempts, dependent: :destroy

  # Validations
  validates :title, presence: true, length: { minimum: 3, maximum: 100 }
  validates :lesson, presence: true
  validates :time_limit_minutes, numericality: { greater_than: 0 }, allow_nil: true
  validates :max_attempts, numericality: { greater_than: 0 }, allow_nil: true
  validates :passing_score, numericality: {
    greater_than_or_equal_to: 0,
    less_than_or_equal_to: 100
  }, allow_nil: true

  # Callbacks
  before_validation :set_defaults, on: :create

  # Instance methods
  def total_points
    quiz_questions.sum(:points)
  end

  def question_count
    quiz_questions.count
  end

  def attempts_for_user(user)
    quiz_attempts.where(user: user)
  end

  def best_attempt_for_user(user)
    attempts_for_user(user).maximum(:score)
  end

  def can_be_attempted_by?(user)
    return false unless user.enrolled_in?(course)
    return true if max_attempts.nil?

    attempts_for_user(user).count < max_attempts
  end

  def is_passed_by?(user)
    return false unless passing_score

    best_score = best_attempt_for_user(user)
    return false unless best_score

    best_score >= passing_score
  end

  def average_score
    return 0 if quiz_attempts.empty?

    quiz_attempts.where.not(score: nil).average(:score).to_f.round(2)
  end

  def completion_rate
    total_enrollments = course.enrollment_count
    return 0 if total_enrollments.zero?

    completed_attempts = quiz_attempts.where(status: :submitted).distinct.count(:user_id)
    (completed_attempts.to_f / total_enrollments * 100).round(2)
  end

  def time_limit_in_seconds
    return nil unless time_limit_minutes

    time_limit_minutes * 60
  end

  def has_time_limit?
    time_limit_minutes.present? && time_limit_minutes > 0
  end

  private

  def set_defaults
    self.max_attempts ||= 3
    self.passing_score ||= 70.0
  end
end
