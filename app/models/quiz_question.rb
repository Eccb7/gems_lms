class QuizQuestion < ApplicationRecord
  # Enums
  enum :question_type, {
    multiple_choice: 0,
    true_false: 1,
    fill_in_blank: 2,
    essay: 3,
    multiple_select: 4
  }  # Associations
  belongs_to :quiz
  has_many :quiz_options, -> { order(:position) }, dependent: :destroy

  # Validations
  validates :quiz, presence: true
  validates :question_text, presence: true, length: { minimum: 10 }
  validates :question_type, presence: true
  validates :position, presence: true, uniqueness: { scope: :quiz_id }
  validates :points, numericality: { greater_than: 0 }
  validate :must_have_correct_options, if: :needs_options?

  # Scopes
  scope :ordered, -> { order(:position) }

  # Callbacks
  before_validation :set_position, on: :create
  before_validation :set_default_points, on: :create

  # Instance methods
  def needs_options?
    multiple_choice? || true_false? || multiple_select?
  end

  def correct_options
    quiz_options.where(is_correct: true)
  end

  def incorrect_options
    quiz_options.where(is_correct: false)
  end

  def has_correct_answer?
    return true if essay? || fill_in_blank?

    correct_options.exists?
  end

  def move_to_position(new_position)
    transaction do
      if new_position > position
        quiz.quiz_questions.where("position > ? AND position <= ?", position, new_position)
            .update_all("position = position - 1")
      else
        quiz.quiz_questions.where("position >= ? AND position < ?", new_position, position)
            .update_all("position = position + 1")
      end

      update!(position: new_position)
    end
  end

  def auto_grade_answer(user_answer)
    case question_type
    when "multiple_choice", "true_false"
      selected_option = quiz_options.find_by(id: user_answer)
      selected_option&.is_correct? ? points : 0
    when "multiple_select"
      selected_option_ids = Array(user_answer).map(&:to_i)
      correct_option_ids = correct_options.pluck(:id).sort
      selected_option_ids.sort == correct_option_ids ? points : 0
    when "fill_in_blank"
      # Simple case-insensitive matching - can be enhanced later
      correct_answer = correct_options.first&.option_text&.downcase
      user_answer&.downcase&.strip == correct_answer ? points : 0
    when "essay"
      # Essays need manual grading
      nil
    else
      0
    end
  end

  private

  def set_position
    return if position.present?

    max_position = quiz.quiz_questions.maximum(:position) || 0
    self.position = max_position + 1
  end

  def set_default_points
    self.points ||= 1.0
  end

  def must_have_correct_options
    return unless persisted? && needs_options?

    unless correct_options.exists?
      errors.add(:base, "must have at least one correct option")
    end
  end
end
