class HomeController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :index ]

  def index
    if user_signed_in?
      redirect_based_on_role
    else
      @featured_courses = Course.published_courses.featured_courses.limit(6)
      @categories = Category.active.limit(8)
      @total_students = User.student.count
      @total_courses = Course.published_courses.count
      @total_instructors = User.instructor.count
    end
  end

  private

  def redirect_based_on_role
    case current_user.role
    when 'student'
      redirect_to student_dashboard_path
    when 'instructor'
      redirect_to instructor_dashboard_path if defined?(instructor_dashboard_path)
    when 'admin'
      redirect_to admin_dashboard_path if defined?(admin_dashboard_path)
    else
      redirect_to student_dashboard_path
    end
  end
end
