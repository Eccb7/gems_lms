class Certificate < ApplicationRecord
  belongs_to :user
  belongs_to :course

  validates :certificate_number, presence: true, uniqueness: true
  validates :issued_at, presence: true

  before_validation :generate_certificate_number, on: :create
  before_validation :set_issued_date, on: :create

  scope :recent, -> { order(issued_at: :desc) }
  scope :by_course, ->(course) { where(course: course) }

  def certificate_url
    Rails.application.routes.url_helpers.certificate_url(self, host: ENV["APP_HOST"] || "localhost:3000")
  end

  def to_pdf
    # Generate PDF certificate using Prawn or similar
    # This would be implemented with a PDF generation service
  end

  private

  def generate_certificate_number
    self.certificate_number = "GEMS-#{Date.current.strftime('%Y')}-#{SecureRandom.alphanumeric(8).upcase}"
  end

  def set_issued_date
    self.issued_at = Time.current
  end
end
