class NotificationService
  class << self
    def create_for_user(user, title, message, notification_type)
      user.notifications.create!(
        title: title,
        message: message,
        notification_type: notification_type
      )
    end

    def create_for_instructor(instructor, title, message, notification_type)
      create_for_user(instructor, title, message, notification_type)
    end

    def create_for_students(students, title, message, notification_type)
      students.each do |student|
        create_for_user(student, title, message, notification_type)
      end
    end

    def create_announcement(users, title, message)
      users.each do |user|
        create_for_user(user, title, message, :announcement)
      end
    end

    def create_course_enrollment_notification(user, course)
      create_for_user(
        user,
        "Course Enrollment Confirmed",
        "You have successfully enrolled in #{course.title}",
        :course_enrollment
      )
    end

    def create_lesson_completion_notification(user, lesson)
      create_for_user(
        user,
        "Lesson Completed",
        "You have completed the lesson: #{lesson.title}",
        :lesson_completed
      )
    end

    def create_course_completion_notification(user, course)
      create_for_user(
        user,
        "Course Completed! 🎉",
        "Congratulations! You have completed #{course.title}",
        :course_completed
      )
    end

    def create_quiz_completion_notification(user, quiz, score)
      create_for_user(
        user,
        "Quiz Completed",
        "You scored #{score}% on the quiz: #{quiz.title}",
        :quiz_completed
      )
    end

    def create_reminder_notification(user, title, message)
      create_for_user(user, title, message, :reminder)
    end

    def create_system_alert(users, title, message)
      users.each do |user|
        create_for_user(user, title, message, :system_alert)
      end
    end

    def mark_all_as_read(user)
      user.notifications.unread.update_all(read: true)
    end

    def cleanup_old_notifications(days_old = 30)
      cutoff_date = days_old.days.ago
      Notification.where("sent_at < ?", cutoff_date).destroy_all
    end
  end
end
