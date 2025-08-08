class AdvancedAnalyticsService
  def self.course_engagement_metrics(course, start_date = 1.month.ago, end_date = Date.current)
    {
      total_enrollments: course.enrollments.where(created_at: start_date..end_date).count,
      active_learners: course.enrollments.joins(:lesson_progresses)
                            .where(lesson_progresses: { created_at: start_date..end_date })
                            .distinct.count,
      completion_rate: calculate_completion_rate(course, start_date, end_date),
      average_progress: calculate_average_progress(course),
      lesson_engagement: lesson_engagement_data(course, start_date, end_date),
      quiz_performance: quiz_performance_data(course, start_date, end_date),
      dropoff_points: calculate_dropoff_points(course)
    }
  end

  def self.instructor_performance_metrics(instructor, start_date = 1.month.ago, end_date = Date.current)
    courses = instructor.created_courses.published

    {
      total_courses: courses.count,
      total_students: courses.joins(:enrollments).distinct.count("enrollments.user_id"),
      average_course_rating: calculate_average_rating(courses),
      revenue: calculate_instructor_revenue(instructor, start_date, end_date),
      student_satisfaction: calculate_student_satisfaction(instructor),
      course_completion_rates: courses.map { |course|
        {
          course_title: course.title,
          completion_rate: calculate_completion_rate(course, start_date, end_date)
        }
      }
    }
  end

  def self.student_learning_analytics(student, start_date = 1.month.ago, end_date = Date.current)
    {
      total_enrollments: student.enrollments.where(created_at: start_date..end_date).count,
      completed_courses: student.completed_courses.count,
      learning_streak: student.current_streak,
      total_study_time: calculate_total_study_time(student, start_date, end_date),
      preferred_learning_times: analyze_learning_patterns(student),
      subject_preferences: analyze_subject_preferences(student),
      achievement_progress: student.achievements.where(created_at: start_date..end_date),
      upcoming_deadlines: upcoming_assignments_and_quizzes(student)
    }
  end

  def self.platform_wide_metrics(start_date = 1.month.ago, end_date = Date.current)
    {
      total_users: User.where(created_at: start_date..end_date).count,
      new_enrollments: Enrollment.where(created_at: start_date..end_date).count,
      course_completions: CourseProgress.where(completed: true, updated_at: start_date..end_date).count,
      revenue: calculate_platform_revenue(start_date, end_date),
      popular_courses: Course.joins(:enrollments)
                            .where(enrollments: { created_at: start_date..end_date })
                            .group("courses.id")
                            .order("COUNT(enrollments.id) DESC")
                            .limit(10),
      user_retention: calculate_user_retention(start_date, end_date),
      peak_usage_times: analyze_peak_usage_times(start_date, end_date)
    }
  end

  private

  def self.calculate_completion_rate(course, start_date, end_date)
    total_enrollments = course.enrollments.where(created_at: start_date..end_date).count
    return 0 if total_enrollments.zero?

    completions = course.course_progresses.where(completed: true, updated_at: start_date..end_date).count
    (completions.to_f / total_enrollments * 100).round(2)
  end

  def self.calculate_average_progress(course)
    progresses = course.course_progresses.pluck(:progress_percentage)
    return 0 if progresses.empty?

    (progresses.sum.to_f / progresses.count).round(2)
  end

  def self.lesson_engagement_data(course, start_date, end_date)
    course.lessons.includes(:lesson_progresses)
          .map do |lesson|
      {
        lesson_title: lesson.title,
        views: lesson.lesson_progresses.where(created_at: start_date..end_date).count,
        completions: lesson.lesson_progresses.where(completed: true, created_at: start_date..end_date).count,
        average_time_spent: lesson.lesson_progresses
                                  .where(created_at: start_date..end_date)
                                  .average(:time_spent_seconds) || 0
      }
    end
  end

  def self.quiz_performance_data(course, start_date, end_date)
    course.quizzes.includes(:quiz_attempts)
          .map do |quiz|
      attempts = quiz.quiz_attempts.where(created_at: start_date..end_date)
      {
        quiz_title: quiz.title,
        total_attempts: attempts.count,
        average_score: attempts.average(:score) || 0,
        pass_rate: calculate_quiz_pass_rate(quiz, start_date, end_date)
      }
    end
  end

  def self.calculate_dropoff_points(course)
    lessons = course.lessons.includes(:lesson_progresses)
    total_enrollments = course.enrollments.count

    lessons.map do |lesson|
      completion_count = lesson.lesson_progresses.where(completed: true).count
      dropoff_rate = total_enrollments > 0 ? (1 - completion_count.to_f / total_enrollments) * 100 : 0

      {
        lesson_title: lesson.title,
        position: lesson.position,
        dropoff_rate: dropoff_rate.round(2)
      }
    end.sort_by { |data| data[:dropoff_rate] }.reverse
  end

  # Additional helper methods would be implemented here
  def self.calculate_average_rating(courses)
    # Implementation depends on review system
    0.0
  end

  def self.calculate_instructor_revenue(instructor, start_date, end_date)
    # Implementation depends on payment system
    0.0
  end

  def self.calculate_student_satisfaction(instructor)
    # Implementation depends on review/rating system
    0.0
  end

  def self.calculate_total_study_time(student, start_date, end_date)
    student.lesson_progresses
           .where(created_at: start_date..end_date)
           .sum(:time_spent_seconds)
  end

  def self.analyze_learning_patterns(student)
    # Analyze when student is most active
    hours = student.lesson_progresses
                   .group_by { |lp| lp.created_at.hour }
                   .transform_values(&:count)

    hours.max_by { |hour, count| count }&.first || 0
  end

  def self.analyze_subject_preferences(student)
    student.enrollments
           .joins(course: :category)
           .group("categories.name")
           .count
  end

  def self.upcoming_assignments_and_quizzes(student)
    # Get assignments and quizzes due in the next 7 days
    student.assignments
           .joins(:lesson)
           .where("assignments.due_date BETWEEN ? AND ?", Date.current, 7.days.from_now)
           .limit(5)
  end

  def self.calculate_platform_revenue(start_date, end_date)
    # Implementation depends on payment system
    0.0
  end

  def self.calculate_user_retention(start_date, end_date)
    # Calculate percentage of users who return within time period
    0.0
  end

  def self.analyze_peak_usage_times(start_date, end_date)
    # Analyze when the platform has highest usage
    {}
  end

  def self.calculate_quiz_pass_rate(quiz, start_date, end_date)
    attempts = quiz.quiz_attempts.where(created_at: start_date..end_date)
    return 0 if attempts.count.zero?

    passed = attempts.where("score >= ?", quiz.passing_score).count
    (passed.to_f / attempts.count * 100).round(2)
  end
end
