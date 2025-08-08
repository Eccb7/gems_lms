class CoursesController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :index, :show ]
  before_action :set_course, only: [ :show, :enroll, :leave ]

  def index
    @courses = Course.published_courses.includes(:instructor, :category, :enrollments)

    # Search functionality
    if params[:search].present?
      @courses = @courses.search_by_title_and_description(params[:search])
    end

    # Filter by category
    if params[:category_id].present?
      @courses = @courses.where(category_id: params[:category_id])
    end

    # Filter by difficulty
    if params[:difficulty].present?
      @courses = @courses.where(difficulty_level: params[:difficulty])
    end

    # Filter by price
    case params[:price_filter]
    when "free"
      @courses = @courses.where(price: 0)
    when "paid"
      @courses = @courses.where("price > 0")
    end

    # Sorting
    case params[:sort]
    when "popular"
      @courses = @courses.popular
    when "newest"
      @courses = @courses.recent
    when "price_low"
      @courses = @courses.order(:price)
    when "price_high"
      @courses = @courses.order(price: :desc)
    else
      @courses = @courses.recent
    end

    @courses = @courses.page(params[:page])

    @categories = Category.active
    @difficulty_levels = Course.difficulty_levels.keys
  end

  def show
    authorize! :read, @course if user_signed_in?

    @enrolled = current_user&.enrolled_in?(@course) if user_signed_in?
    @course_progress = current_user&.course_progress(@course) if @enrolled
    @sections = @course.sections.includes(lessons: [ :quiz, :assignments ])

    @instructor = @course.instructor
    @similar_courses = Course.published_courses
                            .where(category: @course.category)
                            .where.not(id: @course.id)
                            .limit(4)
  end

  def enroll
    authorize! :enroll, @course if user_signed_in?

    if current_user.enrolled_in?(@course)
      redirect_to @course, alert: "You are already enrolled in this course."
      return
    end

    # Only allow direct enrollment for free courses
    unless @course.is_free?
      redirect_to @course, alert: "This is a paid course. Please complete payment to enroll."
      return
    end

    enrollment = current_user.enrollments.build(course: @course)

    if enrollment.save
      # NotificationService.create_course_enrollment_notification(current_user, @course)
      redirect_to @course, notice: "Successfully enrolled in #{@course.title}!"
    else
      redirect_to @course, alert: "Unable to enroll in this course. #{enrollment.errors.full_messages.join(', ')}"
    end
  end

  def leave
    enrollment = current_user.enrollments.find_by(course: @course)

    if enrollment
      enrollment.destroy
      redirect_to courses_path, notice: "You have left the course."
    else
      redirect_to @course, alert: "You are not enrolled in this course."
    end
  end

  private

  def set_course
    @course = Course.find(params[:id])
  end
end
