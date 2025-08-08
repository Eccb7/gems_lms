class AnalyticsService
  class << self
    def platform_overview
      {
        total_users: User.count,
        total_students: User.student.count,
        total_instructors: User.instructor.count,
        total_admins: User.admin.count,
        active_users: User.active.count,
        total_courses: Course.count,
        published_courses: Course.published_courses.count,
        total_enrollments: Enrollment.count,
        total_lessons: Lesson.count,
        total_quizzes: Quiz.count
      }
    end

    def user_engagement_stats
      {
        new_users_this_month: User.where("created_at >= ?", 1.month.ago).count,
        active_enrollments: Enrollment.active.count,
        completed_courses: CourseProgress.completed.count,
        total_quiz_attempts: QuizAttempt.count,
        completed_lessons: LessonProgress.completed.count
      }
    end

    def course_performance
      Course.published_courses.includes(:enrollments, :course_progresses).map do |course|
        {
          id: course.id,
          title: course.title,
          instructor: course.instructor.display_name,
          enrollment_count: course.enrollment_count,
          completion_rate: course.completion_rate,
          average_progress: course.course_progresses.average(:progress_percentage)&.round(2) || 0
        }
      end
    end

    def popular_courses(limit = 10)
      Course.published_courses
            .left_joins(:enrollments)
            .group("courses.id")
            .order("COUNT(enrollments.id) DESC")
            .limit(limit)
            .pluck("courses.title", "COUNT(enrollments.id)")
    end

    def top_performing_instructors(limit = 10)
      User.instructor
          .joins(created_courses: :course_progresses)
          .group("users.id")
          .order("AVG(course_progresses.progress_percentage) DESC")
          .limit(limit)
          .pluck("users.first_name || ' ' || users.last_name", "AVG(course_progresses.progress_percentage)")
    end

    def monthly_enrollments(months = 12)
      months.times.map do |i|
        date = i.months.ago.beginning_of_month
        count = Enrollment.where(enrolled_at: date..date.end_of_month).count
        [ date.strftime("%b %Y"), count ]
      end.reverse
    end

    def course_completion_trends(months = 12)
      months.times.map do |i|
        date = i.months.ago.beginning_of_month
        count = CourseProgress.where(completed_at: date..date.end_of_month, completed: true).count
        [ date.strftime("%b %Y"), count ]
      end.reverse
    end

    def quiz_performance_overview
      {
        total_attempts: QuizAttempt.count,
        average_score: QuizAttempt.where.not(score: nil).average(:score)&.round(2) || 0,
        completion_rate: quiz_completion_rate,
        most_difficult_quizzes: most_difficult_quizzes(5)
      }
    end

    def assignment_stats
      {
        total_assignments: Assignment.count,
        total_submissions: AssignmentSubmission.submitted_submissions.count,
        average_grade: AssignmentSubmission.graded_submissions.where.not(grade: nil).average(:grade)&.round(2) || 0,
        pending_grading: AssignmentSubmission.pending_grading.count
      }
    end

    def student_progress_distribution
      {
        not_started: CourseProgress.not_started.count,
        in_progress: CourseProgress.in_progress.count,
        completed: CourseProgress.completed.count
      }
    end

    def recent_activity(limit = 50)
      activities = []

      # Recent enrollments
      Enrollment.recent.limit(limit).includes(:user, :course).each do |enrollment|
        activities << {
          type: "enrollment",
          message: "#{enrollment.user.display_name} enrolled in #{enrollment.course.title}",
          timestamp: enrollment.enrolled_at,
          user: enrollment.user.display_name
        }
      end

      # Recent course completions
      CourseProgress.where(completed: true).recent.limit(limit).includes(:user, :course).each do |progress|
        activities << {
          type: "completion",
          message: "#{progress.user.display_name} completed #{progress.course.title}",
          timestamp: progress.completed_at,
          user: progress.user.display_name
        }
      end

      activities.sort_by { |a| a[:timestamp] }.reverse.first(limit)
    end

    private

    def quiz_completion_rate
      total_enrollments = Enrollment.count
      return 0 if total_enrollments.zero?

      completed_quizzes = QuizAttempt.submitted.count
      (completed_quizzes.to_f / total_enrollments * 100).round(2)
    end

    def most_difficult_quizzes(limit)
      Quiz.joins(:quiz_attempts)
          .where(quiz_attempts: { status: :submitted })
          .group("quizzes.id")
          .order("AVG(quiz_attempts.score) ASC")
          .limit(limit)
          .pluck("quizzes.title", "AVG(quiz_attempts.score)")
    end
  end
end
