class Admin::DashboardController < ApplicationController
  before_action :ensure_admin

  def index
    @platform_stats = AnalyticsService.platform_overview
    @user_engagement = AnalyticsService.user_engagement_stats

    @recent_activity = AnalyticsService.recent_activity(20)
    @pending_course_approvals = Course.pending_approval.includes(:instructor, :category).limit(10)

    @course_performance = AnalyticsService.course_performance.first(10)
    @popular_courses = AnalyticsService.popular_courses(5)
    @top_instructors = AnalyticsService.top_performing_instructors(5)

    @monthly_enrollments = AnalyticsService.monthly_enrollments(6)
    @completion_trends = AnalyticsService.course_completion_trends(6)

    @system_health = {
      active_users_today: User.joins(:notifications).where("notifications.sent_at > ?", 1.day.ago).distinct.count,
      courses_created_this_week: Course.where("created_at > ?", 1.week.ago).count,
      enrollments_this_week: Enrollment.where("enrolled_at > ?", 1.week.ago).count
    }
  end

  def analytics
    @platform_overview = AnalyticsService.platform_overview
    @user_engagement = AnalyticsService.user_engagement_stats
    @quiz_performance = AnalyticsService.quiz_performance_overview
    @assignment_stats = AnalyticsService.assignment_stats
    @progress_distribution = AnalyticsService.student_progress_distribution

    @monthly_data = {
      enrollments: AnalyticsService.monthly_enrollments(12),
      completions: AnalyticsService.course_completion_trends(12)
    }

    @course_analytics = AnalyticsService.course_performance
    @instructor_performance = AnalyticsService.top_performing_instructors(15)
  end

  private

  def ensure_admin
    redirect_to root_path, alert: "Access denied." unless current_user&.admin?
  end
end
