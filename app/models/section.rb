class Section < ApplicationRecord
  # Associations
  belongs_to :course
  has_many :lessons, -> { order(:position) }, dependent: :destroy

  # Validations
  validates :title, presence: true, length: { minimum: 3, maximum: 100 }
  validates :course, presence: true
  validates :position, presence: true, uniqueness: { scope: :course_id }

  # Scopes
  scope :ordered, -> { order(:position) }

  # Callbacks
  before_validation :set_position, on: :create

  # Instance methods
  def total_duration
    lessons.sum(:duration_minutes)
  end

  def lesson_count
    lessons.count
  end

  def move_to_position(new_position)
    transaction do
      if new_position > position
        course.sections.where("position > ? AND position <= ?", position, new_position)
              .update_all("position = position - 1")
      else
        course.sections.where("position >= ? AND position < ?", new_position, position)
              .update_all("position = position + 1")
      end

      update!(position: new_position)
    end
  end

  private

  def set_position
    return if position.present?

    max_position = course.sections.maximum(:position) || 0
    self.position = max_position + 1
  end
end
