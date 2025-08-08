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
end
