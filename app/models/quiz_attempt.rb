class QuizAttempt < ApplicationRecord
  # Enums
  enum :status, { in_progress: 0, submitted: 1, timed_out: 2, abandoned: 3 }

  # Associations
  belongs_to :user
  belongs_to :quiz
  has_one :course, through: :quiz

  # Validations
  validates :user, presence: true
  validates :quiz, presence: true
  validates :started_at, presence: true
  validates :score, numericality: {
    greater_than_or_equal_to: 0,
    less_than_or_equal_to: 100
  }, allow_nil: true
  validate :user_can_attempt_quiz

  # Scopes
  scope :recent, -> { order(started_at: :desc) }
  scope :completed, -> { where(status: [ :submitted, :timed_out ]) }
  scope :best_scores, -> { group(:user_id).maximum(:score) }

  # Store answers as JSON
  store_accessor :answers, :question_answers

  # Callbacks
  before_validation :set_started_at, on: :create
  after_create :initialize_answers
  before_save :calculate_score, if: :will_save_change_to_answers?

  # Instance methods
  def duration_in_seconds
    return 0 unless started_at

    end_time = submitted_at || Time.current
    (end_time - started_at).to_i
  end

  def duration_formatted
    seconds = duration_in_seconds
    hours = seconds / 3600
    minutes = (seconds % 3600) / 60
    seconds = seconds % 60

    if hours > 0
      sprintf("%02d:%02d:%02d", hours, minutes, seconds)
    else
      sprintf("%02d:%02d", minutes, seconds)
    end
  end

  def time_remaining_seconds
    return nil unless quiz.has_time_limit?
    return 0 if submitted?

    time_limit = quiz.time_limit_in_seconds
    elapsed = duration_in_seconds
    [ time_limit - elapsed, 0 ].max
  end

  def is_time_expired?
    return false unless quiz.has_time_limit?

    time_remaining_seconds <= 0
  end

  def submit!
    transaction do
      calculate_score
      update!(
        status: :submitted,
        submitted_at: Time.current
      )

      # Mark lesson as completed if passing score is met
      if passed?
        quiz.lesson.mark_completed_by(user)
      end
    end
  end

  def abandon!
    update!(status: :abandoned)
  end

  def timeout!
    transaction do
      calculate_score
      update!(
        status: :timed_out,
        submitted_at: Time.current
      )
    end
  end

  def passed?
    return false unless score && quiz.passing_score

    score >= quiz.passing_score
  end

  def percentage_score
    return 0 unless score

    score.round(2)
  end

  def answer_for_question(question)
    return nil unless question_answers

    question_answers[question.id.to_s]
  end

  def set_answer_for_question(question, answer)
    self.question_answers ||= {}
    self.question_answers[question.id.to_s] = answer
  end

  def total_possible_points
    quiz.total_points
  end

  def points_earned
    return 0 unless total_possible_points > 0

    (score * total_possible_points / 100).round(2)
  end

  private

  def set_started_at
    self.started_at ||= Time.current
  end

  def initialize_answers
    self.question_answers = {}
    save!
  end

  def user_can_attempt_quiz
    return unless user && quiz

    unless quiz.can_be_attempted_by?(user)
      errors.add(:base, "You have exceeded the maximum number of attempts for this quiz")
    end
  end

  def calculate_score
    return unless question_answers

    total_points = 0
    earned_points = 0

    quiz.quiz_questions.includes(:quiz_options).each do |question|
      total_points += question.points

      user_answer = question_answers[question.id.to_s]
      next unless user_answer

      earned = question.auto_grade_answer(user_answer)
      earned_points += earned if earned
    end

    self.score = total_points > 0 ? (earned_points.to_f / total_points * 100).round(2) : 0
  end
end
