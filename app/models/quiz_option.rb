class QuizOption < ApplicationRecord
  # Associations
  belongs_to :quiz_question

  # Validations
  validates :quiz_question, presence: true
  validates :option_text, presence: true, length: { minimum: 1, maximum: 500 }
  validates :position, presence: true, uniqueness: { scope: :quiz_question_id }

  # Scopes
  scope :ordered, -> { order(:position) }
  scope :correct, -> { where(is_correct: true) }
  scope :incorrect, -> { where(is_correct: false) }

  # Callbacks
  before_validation :set_position, on: :create
  after_save :ensure_single_correct_for_single_choice

  # Instance methods
  def move_to_position(new_position)
    transaction do
      if new_position > position
        quiz_question.quiz_options.where("position > ? AND position <= ?", position, new_position)
                     .update_all("position = position - 1")
      else
        quiz_question.quiz_options.where("position >= ? AND position < ?", new_position, position)
                     .update_all("position = position + 1")
      end

      update!(position: new_position)
    end
  end

  def toggle_correctness!
    update!(is_correct: !is_correct)
  end

  private

  def set_position
    return if position.present?

    max_position = quiz_question.quiz_options.maximum(:position) || 0
    self.position = max_position + 1
  end

  def ensure_single_correct_for_single_choice
    return unless is_correct_changed? && is_correct?
    return unless quiz_question.multiple_choice? || quiz_question.true_false?

    # For single-choice questions, ensure only one correct answer
    quiz_question.quiz_options.where.not(id: id).update_all(is_correct: false)
  end
end
