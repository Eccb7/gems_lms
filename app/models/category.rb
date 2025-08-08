class Category < ApplicationRecord
  # Associations
  has_many :courses, dependent: :destroy

  # Validations
  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :color, format: { with: /\A#[0-9A-Fa-f]{6}\z/, message: "must be a valid hex color" }, allow_blank: true

  # Scopes
  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }
  scope :by_name, -> { order(:name) }

  # Callbacks
  before_validation :set_default_values, on: :create

  # Instance methods
  def courses_count
    courses.count
  end

  def toggle_status!
    update!(active: !active)
  end

  private

  def set_default_values
    self.active = true if active.nil?
    self.color = generate_random_color if color.blank?
  end

  def generate_random_color
    "##{SecureRandom.hex(3)}"
  end
end
