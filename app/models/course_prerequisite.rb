class CoursePrerequisite < ApplicationRecord
  belongs_to :course
  belongs_to :prerequisite_course, class_name: 'Course'

  validates :course_id, uniqueness: { scope: :prerequisite_course_id }
  validate :no_circular_dependency

  private

  def no_circular_dependency
    if prerequisite_course == course
      errors.add(:prerequisite_course, "cannot be the same as the course")
    end

    # Check for circular dependencies
    if course.has_prerequisite_chain_to?(prerequisite_course)
      errors.add(:prerequisite_course, "would create a circular dependency")
    end
  end
end
