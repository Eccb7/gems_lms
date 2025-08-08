class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user (not logged in)

    if user.admin?
      can :manage, :all
    elsif user.instructor?
      instructor_abilities(user)
    elsif user.student?
      student_abilities(user)
    end

    # Common abilities for all authenticated users
    if user.persisted?
      can :read, User, id: user.id
      can :update, User, id: user.id
      can :read, Notification, user_id: user.id
      can :update, Notification, user_id: user.id
    end
  end

  private

  def instructor_abilities(user)
    # Course management
    can :create, Course
    can :manage, Course, instructor_id: user.id
    can :read, Course, status: :published
    can :read, Course, instructor_id: user.id

    # Section and Lesson management for own courses
    can :manage, Section do |section|
      section.course.instructor_id == user.id
    end

    can :manage, Lesson do |lesson|
      lesson.course.instructor_id == user.id
    end

    # Quiz and Assignment management for own courses
    can :manage, Quiz do |quiz|
      quiz.course.instructor_id == user.id
    end

    can :manage, Assignment do |assignment|
      assignment.course.instructor_id == user.id
    end

    # View student submissions and grade them
    can :read, AssignmentSubmission do |submission|
      submission.course.instructor_id == user.id
    end

    can :grade, AssignmentSubmission do |submission|
      submission.course.instructor_id == user.id
    end

    # View enrollments for own courses
    can :read, Enrollment do |enrollment|
      enrollment.course.instructor_id == user.id
    end

    # View course progress for own courses
    can :read, CourseProgress do |progress|
      progress.course.instructor_id == user.id
    end

    # Categories (read only)
    can :read, Category
  end

  def student_abilities(user)
    # Course browsing and enrollment
    can :read, Course, status: :published
    can :enroll, Course do |course|
      course.can_be_enrolled_by?(user)
    end

    # Access enrolled course content
    can :read, Section do |section|
      user.enrolled_in?(section.course)
    end

    can :read, Lesson do |lesson|
      lesson.can_be_accessed_by?(user)
    end

    # Quiz attempts
    can :create, QuizAttempt do |attempt|
      attempt.quiz.can_be_attempted_by?(user)
    end

    can :read, QuizAttempt, user_id: user.id
    can :update, QuizAttempt, user_id: user.id, status: :in_progress

    # Assignment submissions
    can :create, AssignmentSubmission do |submission|
      submission.assignment.can_be_submitted_by?(user)
    end

    can :manage, AssignmentSubmission, user_id: user.id, status: [ :draft, :returned ]
    can :read, AssignmentSubmission, user_id: user.id

    # Own progress tracking
    can :read, Enrollment, user_id: user.id
    can :read, CourseProgress, user_id: user.id
    can :read, LessonProgress, user_id: user.id

    # Categories (read only)
    can :read, Category
  end
end
