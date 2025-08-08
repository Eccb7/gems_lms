class StudentsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_student!

  def dashboard
    @enrolled_courses = current_user.enrolled_courses.includes(:course).joins(:course)
    @recent_activities = current_user.activities.recent.limit(5)
    @upcoming_deadlines = current_user.assignments.upcoming.limit(3)
    @achievements = current_user.achievements.recent.limit(3)
    @progress_stats = calculate_progress_stats
  end

  private

  def ensure_student!
    redirect_to root_path unless current_user.student?
  end

  def calculate_progress_stats
    {
      total_courses: @enrolled_courses.count,
      completed_courses: @enrolled_courses.joins(:course).where(courses: { status: 'completed' }).count,
      total_lessons: current_user.lessons.count,
      completed_lessons: current_user.lesson_completions.count,
      total_points: current_user.total_points || 0,
      current_streak: current_user.current_streak || 0
    }
  end
end
