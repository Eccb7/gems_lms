class Instructor::CoursesController < ApplicationController
  before_action :ensure_instructor
  before_action :set_course, only: [ :show, :edit, :update, :destroy, :publish, :analytics ]

  def index
    @courses = current_user.created_courses
                          .includes(:category, :enrollments)
                          .order(created_at: :desc)
                          .page(params[:page])
  end

  def show
    @sections = @course.sections.includes(lessons: [ :quiz, :assignments ])
    @course_stats = {
      enrollment_count: @course.enrollment_count,
      completion_rate: @course.completion_rate,
      total_lessons: @course.total_lessons,
      total_duration: @course.total_duration
    }
    @recent_enrollments = @course.enrollments.recent.includes(:user).limit(5)
  end

  def new
    @course = Course.new
    @categories = Category.active
  end

  def create
    @course = current_user.created_courses.build(course_params)

    if @course.save
      redirect_to [ :instructor, @course ], notice: "Course was successfully created."
    else
      @categories = Category.active
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @categories = Category.active
  end

  def update
    if @course.update(course_params)
      redirect_to [ :instructor, @course ], notice: "Course was successfully updated."
    else
      @categories = Category.active
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @course.destroy
    redirect_to instructor_courses_path, notice: "Course was successfully deleted."
  end

  def publish
    if @course.can_be_published?
      @course.update(status: :pending_approval)
      redirect_to [ :instructor, @course ], notice: "Course submitted for approval."
    else
      redirect_to [ :instructor, @course ], alert: "Course cannot be published yet. Please add content first."
    end
  end

  def analytics
    @enrollment_stats = {
      total_enrollments: @course.enrollment_count,
      active_students: @course.enrollments.active.count,
      completed_students: @course.course_progresses.completed.count,
      dropout_rate: calculate_dropout_rate
    }

    @lesson_analytics = lesson_completion_stats
    @quiz_analytics = quiz_performance_stats
    @assignment_analytics = assignment_submission_stats

    @monthly_enrollments = monthly_enrollment_data
    @progress_distribution = progress_distribution_data
  end

  private

  def ensure_instructor
    redirect_to root_path, alert: "Access denied." unless current_user&.can_create_courses?
  end

  def set_course
    @course = current_user.created_courses.find(params[:id])
  end

  def course_params
    params.require(:course).permit(:title, :description, :objectives, :prerequisites,
                                  :price, :category_id, :difficulty_level, :featured,
                                  :cover_image, :promotional_video)
  end

  def calculate_dropout_rate
    total_enrollments = @course.enrollment_count
    return 0 if total_enrollments.zero?

    dropped_enrollments = @course.enrollments.dropped.count
    (dropped_enrollments.to_f / total_enrollments * 100).round(2)
  end

  def lesson_completion_stats
    @course.lessons.includes(:lesson_progresses).map do |lesson|
      completed_count = lesson.lesson_progresses.completed.count
      total_enrolled = @course.enrollment_count
      completion_rate = total_enrolled.zero? ? 0 : (completed_count.to_f / total_enrolled * 100).round(2)

      {
        lesson: lesson,
        completion_rate: completion_rate,
        completed_count: completed_count
      }
    end
  end

  def quiz_performance_stats
    @course.quizzes.includes(:quiz_attempts).map do |quiz|
      attempts = quiz.quiz_attempts.submitted

      {
        quiz: quiz,
        total_attempts: attempts.count,
        average_score: attempts.average(:score)&.round(2) || 0,
        pass_rate: calculate_quiz_pass_rate(quiz, attempts)
      }
    end
  end

  def assignment_submission_stats
    @course.assignments.includes(:assignment_submissions).map do |assignment|
      submissions = assignment.assignment_submissions.submitted_submissions

      {
        assignment: assignment,
        submission_count: submissions.count,
        average_grade: submissions.where.not(grade: nil).average(:grade)&.round(2) || 0,
        pending_grading: assignment.assignment_submissions.pending_grading.count
      }
    end
  end

  def calculate_quiz_pass_rate(quiz, attempts)
    return 0 if attempts.empty? || quiz.passing_score.nil?

    passed_attempts = attempts.where("score >= ?", quiz.passing_score).count
    (passed_attempts.to_f / attempts.count * 100).round(2)
  end

  def monthly_enrollment_data
    12.times.map do |i|
      date = i.months.ago.beginning_of_month
      count = @course.enrollments.where(enrolled_at: date..date.end_of_month).count
      [ date.strftime("%b %Y"), count ]
    end.reverse
  end

  def progress_distribution_data
    progresses = @course.course_progresses.pluck(:progress_percentage)

    {
      not_started: progresses.count { |p| p.nil? || p == 0 },
      in_progress: progresses.count { |p| p && p > 0 && p < 100 },
      completed: progresses.count { |p| p == 100 }
    }
  end
end
