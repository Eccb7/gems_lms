class Student::DashboardController < ApplicationController
  before_action :ensure_student

  def index
    @enrolled_courses = current_user.enrolled_courses
                                   .includes(:category, :instructor, :course_progresses)
                                   .order("enrollments.enrolled_at DESC")

    @course_progresses = current_user.course_progresses
                                    .includes(:course)
                                    .order(:last_accessed_at)

    @recent_notifications = current_user.notifications
                                       .recent
                                       .limit(5)

    @upcoming_deadlines = upcoming_assignments_and_quizzes

    @completed_courses_count = current_user.course_progresses.completed.count
    @total_enrolled_courses = current_user.enrolled_courses.count
    @total_certificates = @completed_courses_count # For future certificate feature

    @recent_achievements = recent_achievements
  end

  private

  def ensure_student
    redirect_to root_path, alert: "Access denied." unless current_user&.student?
  end

  def upcoming_assignments_and_quizzes
    enrolled_course_ids = current_user.enrolled_courses.pluck(:id)

    assignments = Assignment.joins(lesson: { section: :course })
                           .where(courses: { id: enrolled_course_ids })
                           .where("due_date > ?", Time.current)
                           .where.not(id: current_user.assignment_submissions.where(status: [ :submitted, :graded ]).select(:assignment_id))
                           .order(:due_date)
                           .limit(5)

    # For quizzes, we'd need to track which ones have time limits or due dates
    # For now, return assignments only
    assignments
  end

  def recent_achievements
    achievements = []

    # Recent course completions
    recent_completions = current_user.course_progresses
                                    .completed
                                    .where("completed_at > ?", 1.week.ago)
                                    .includes(:course)

    recent_completions.each do |progress|
      achievements << {
        type: "course_completion",
        title: "Course Completed",
        description: "Completed #{progress.course.title}",
        earned_at: progress.completed_at,
        icon: "graduation-cap"
      }
    end

    # Recent quiz achievements (high scores)
    recent_quiz_attempts = current_user.quiz_attempts
                                      .submitted
                                      .where("submitted_at > ?", 1.week.ago)
                                      .where("score >= 90")
                                      .includes(quiz: :lesson)

    recent_quiz_attempts.each do |attempt|
      achievements << {
        type: "quiz_achievement",
        title: "Quiz Excellence",
        description: "Scored #{attempt.score}% on #{attempt.quiz.title}",
        earned_at: attempt.submitted_at,
        icon: "star"
      }
    end

    achievements.sort_by { |a| a[:earned_at] }.reverse.first(5)
  end
end
