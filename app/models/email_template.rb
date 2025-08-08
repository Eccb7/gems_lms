class EmailTemplate < ApplicationRecord
  validates :name, presence: true, uniqueness: true
  validates :subject, presence: true
  validates :body, presence: true
  validates :template_type, presence: true

  enum template_type: {
    welcome_email: 0,
    course_enrollment: 1,
    course_completion: 2,
    certificate_issued: 3,
    assignment_due: 4,
    quiz_reminder: 5,
    instructor_approval: 6,
    password_reset: 7,
    weekly_digest: 8,
    course_announcement: 9
  }

  scope :active, -> { where(active: true) }

  def render_template(variables = {})
    rendered_subject = subject
    rendered_body = body

    variables.each do |key, value|
      placeholder = "{{#{key}}}"
      rendered_subject = rendered_subject.gsub(placeholder, value.to_s)
      rendered_body = rendered_body.gsub(placeholder, value.to_s)
    end

    {
      subject: rendered_subject,
      body: rendered_body
    }
  end

  def self.render_for_type(template_type, variables = {})
    template = active.find_by(template_type: template_type)
    return nil unless template

    template.render_template(variables)
  end
end
