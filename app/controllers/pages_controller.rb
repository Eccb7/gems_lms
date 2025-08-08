class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [:landing, :about, :contact, :privacy, :terms]

  def landing
    # Landing page for non-authenticated users
    @featured_courses = Course.published_courses.featured.limit(6)
    @categories = Category.active.limit(8)
    @total_students = User.student.count
    @total_courses = Course.published_courses.count
    @total_instructors = User.instructor.count
  end

  def about
    # About page
  end

  def contact
    # Contact page
  end

  def privacy
    # Privacy policy
  end

  def terms
    # Terms of service
  end
end
