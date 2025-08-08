class Instructor::DashboardController < ApplicationController
  before_action :ensure_instructor

  def index
    @my_courses = current_user.created_courses
                             .includes(:category, :enrollments, :course_progresses)
                             .order(created_at: :desc)

    @total_students = current_user.created_courses
                                 .joins(:enrollments)
                                 .distinct
                                 .count("enrollments.user_id")

    @total_courses = @my_courses.count
    @published_courses = @my_courses.published_courses.count
    @draft_courses = @my_courses.where(status: :draft).count

    @recent_enrollments = recent_enrollments
    @pending_submissions = pending_assignment_submissions

    @course_analytics = course_performance_analytics
    @recent_notifications = current_user.notifications.recent.limit(5)
  end

  private

  def ensure_instructor
    redirect_to root_path, alert: "Access denied." unless current_user&.instructor? || current_user&.admin?
  end

  def recent_enrollments
    Enrollment.joins(:course)
              .where(courses: { instructor_id: current_user.id })
              .includes(:user, :course)
              .order(enrolled_at: :desc)
              .limit(10)
  end

  def pending_assignment_submissions
    AssignmentSubmission.joins(assignment: { lesson: { section: :course } })
                       .where(courses: { instructor_id: current_user.id })
                       .where(status: :submitted)
                       .includes(:user, assignment: :lesson)
                       .order(submitted_at: :desc)
                       .limit(10)
  end

  def course_performance_analytics
    @my_courses.published_courses.map do |course|
      {
        course: course,
        enrollment_count: course.enrollment_count,
        completion_rate: course.completion_rate,
        average_progress: course.course_progresses.average(:progress_percentage)&.round(2) || 0,
        total_revenue: course.enrollments.count * course.price
      }
    end
  end
end
