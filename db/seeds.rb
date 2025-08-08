# Create default categories
puts "Creating categories..."
categories = [
  { name: "Programming", description: "Learn programming languages and software development", color: "#3B82F6" },
  { name: "Data Science", description: "Data analysis, machine learning, and statistics", color: "#8B5CF6" },
  { name: "Design", description: "UI/UX Design, Graphic Design, and Creative Arts", color: "#EC4899" },
  { name: "Business", description: "Entrepreneurship, Marketing, and Business Management", color: "#10B981" },
  { name: "Mathematics", description: "Mathematics, Statistics, and Mathematical Concepts", color: "#F59E0B" },
  { name: "Language", description: "Foreign languages and communication skills", color: "#EF4444" }
]

categories.each do |cat_attrs|
  Category.find_or_create_by(name: cat_attrs[:name]) do |category|
    category.description = cat_attrs[:description]
    category.color = cat_attrs[:color]
    category.active = true
  end
end

# Create admin user
puts "Creating admin user..."
admin = User.find_or_create_by(email: "admin@gems-lms.com") do |user|
  user.first_name = "System"
  user.last_name = "Administrator"
  user.password = "password123"
  user.password_confirmation = "password123"
  user.role = "admin"
  user.date_of_birth = 30.years.ago
  user.active = true
end

# Create sample instructors
puts "Creating instructor users..."
instructors = [
  {
    email: "john.doe@gems-lms.com",
    first_name: "John",
    last_name: "Doe",
    bio: "Senior Software Engineer with 10+ years of experience in web development and programming education."
  },
  {
    email: "jane.smith@gems-lms.com",
    first_name: "Jane",
    last_name: "Smith",
    bio: "Data Scientist and ML Engineer passionate about teaching data science and analytics."
  },
  {
    email: "mike.wilson@gems-lms.com",
    first_name: "Mike",
    last_name: "Wilson",
    bio: "UX/UI Designer with expertise in modern design principles and user experience."
  }
]

created_instructors = []
instructors.each do |instructor_attrs|
  instructor = User.find_or_create_by(email: instructor_attrs[:email]) do |user|
    user.first_name = instructor_attrs[:first_name]
    user.last_name = instructor_attrs[:last_name]
    user.password = "password123"
    user.password_confirmation = "password123"
    user.role = "instructor"
    user.bio = instructor_attrs[:bio]
    user.date_of_birth = rand(25..45).years.ago
    user.active = true
  end
  created_instructors << instructor
end

# Create sample students
puts "Creating student users..."
students = []
10.times do |i|
  student = User.find_or_create_by(email: "student#{i+1}@gems-lms.com") do |user|
    user.first_name = "Student"
    user.last_name = "#{i+1}"
    user.password = "password123"
    user.password_confirmation = "password123"
    user.role = "student"
    user.date_of_birth = rand(18..30).years.ago
    user.active = true
  end
  students << student
end

# Create sample courses
puts "Creating sample courses..."
programming_category = Category.find_by(name: "Programming")
data_science_category = Category.find_by(name: "Data Science")
design_category = Category.find_by(name: "Design")

courses_data = [
  {
    title: "Complete Ruby on Rails Bootcamp",
    description: "Learn Ruby on Rails from scratch and build real-world web applications. This comprehensive course covers everything from Ruby basics to advanced Rails concepts including testing, deployment, and best practices.",
    objectives: "• Master Ruby programming fundamentals\n• Build complete web applications with Rails\n• Understand MVC architecture\n• Learn database design and Active Record\n• Implement user authentication and authorization\n• Deploy applications to production",
    prerequisites: "Basic understanding of HTML and CSS. No prior programming experience required.",
    price: 99.99,
    category: programming_category,
    instructor: created_instructors[0],
    difficulty_level: "beginner",
    featured: true,
    status: "published"
  },
  {
    title: "Data Science with Python",
    description: "Comprehensive data science course using Python. Learn data analysis, visualization, machine learning, and statistical modeling with real-world projects and datasets.",
    objectives: "• Master Python for data science\n• Learn pandas, numpy, and matplotlib\n• Understand statistical concepts\n• Build machine learning models\n• Create data visualizations\n• Work with real datasets",
    prerequisites: "Basic Python knowledge recommended but not required.",
    price: 149.99,
    category: data_science_category,
    instructor: created_instructors[1],
    difficulty_level: "intermediate",
    featured: true,
    status: "published"
  },
  {
    title: "Modern UI/UX Design Principles",
    description: "Learn modern design principles and create stunning user interfaces. This course covers design theory, prototyping, user research, and industry-standard design tools.",
    objectives: "• Understand design fundamentals\n• Learn color theory and typography\n• Master design tools like Figma\n• Conduct user research\n• Create prototypes and wireframes\n• Design responsive interfaces",
    prerequisites: "No prior design experience required.",
    price: 79.99,
    category: design_category,
    instructor: created_instructors[2],
    difficulty_level: "beginner",
    featured: false,
    status: "published"
  },
  {
    title: "Advanced JavaScript and React",
    description: "Master modern JavaScript and React development. Build complex single-page applications with state management, routing, and API integration.",
    objectives: "• Master ES6+ JavaScript features\n• Build React applications\n• Implement state management\n• Work with APIs\n• Testing JavaScript applications\n• Deploy React apps",
    prerequisites: "Basic JavaScript and HTML/CSS knowledge required.",
    price: 129.99,
    category: programming_category,
    instructor: created_instructors[0],
    difficulty_level: "advanced",
    featured: true,
    status: "published"
  },
  {
    title: "Free Introduction to Programming",
    description: "A completely free course to get started with programming. Learn fundamental concepts that apply to any programming language.",
    objectives: "• Understand programming concepts\n• Learn problem-solving skills\n• Introduction to algorithms\n• Basic programming syntax\n• Debugging techniques",
    prerequisites: "No prerequisites - perfect for complete beginners.",
    price: 0.0,
    category: programming_category,
    instructor: created_instructors[0],
    difficulty_level: "beginner",
    featured: true,
    status: "published"
  }
]

created_courses = []
courses_data.each do |course_attrs|
  course = Course.create!(course_attrs.merge(published_at: Time.current))
  created_courses << course

  # Remove the default section that was auto-created
  course.sections.destroy_all

  # Create sections and lessons for each course
  3.times do |section_index|
    section = course.sections.create!(
      title: "Section #{section_index + 1}: #{[ 'Introduction', 'Core Concepts', 'Advanced Topics' ][section_index]}",
      description: "This section covers important concepts and practical applications.",
      position: section_index + 1
    )

    # Create lessons for each section
    5.times do |lesson_index|
      lesson = section.lessons.create!(
        title: "Lesson #{lesson_index + 1}: #{[ 'Getting Started', 'Basic Concepts', 'Practical Examples', 'Advanced Techniques', 'Project Work' ][lesson_index]}",
        content: "This is the content for lesson #{lesson_index + 1}. In this lesson, you will learn important concepts and get hands-on experience with practical examples.",
        lesson_type: [ 'video', 'text', 'video', 'assignment', 'quiz' ][lesson_index],
        position: lesson_index + 1,
        duration_minutes: rand(15..45)
      )

      # Create a quiz for quiz lessons
      if lesson.quiz?
        quiz = lesson.create_quiz!(
          title: "Quiz: #{lesson.title}",
          description: "Test your understanding of the concepts covered in this lesson.",
          time_limit_minutes: 30,
          max_attempts: 3,
          passing_score: 70.0
        )

        # Create quiz questions
        3.times do |q_index|
          question = quiz.quiz_questions.create!(
            question_text: "What is the main concept covered in this lesson about #{lesson.title}?",
            question_type: "multiple_choice",
            position: q_index + 1,
            points: 10.0
          )

          # Create quiz options
          options = [
            { text: "Correct answer about the main concept", correct: true },
            { text: "Incorrect option A", correct: false },
            { text: "Incorrect option B", correct: false },
            { text: "Incorrect option C", correct: false }
          ]

          options.each_with_index do |option, opt_index|
            question.quiz_options.create!(
              option_text: option[:text],
              is_correct: option[:correct],
              position: opt_index + 1
            )
          end
        end
      end

      # Create assignments for assignment lessons
      if lesson.assignment?
        lesson.assignments.create!(
          title: "Assignment: #{lesson.title}",
          description: "Complete this practical assignment to demonstrate your understanding of the concepts.",
          due_date: 2.weeks.from_now,
          max_points: 100.0,
          submission_format: "both"
        )
      end
    end
  end
end

# Create sample enrollments
puts "Creating sample enrollments..."
students.each do |student|
  # Enroll each student in 2-3 random courses
  sample_courses = created_courses.sample(rand(2..3))
  sample_courses.each do |course|
    enrollment = student.enrollments.create!(
      course: course,
      enrolled_at: rand(30.days).seconds.ago,
      status: "active"
    )

    # Create some progress for enrolled students
    completed_lessons = course.lessons.sample(rand(1..3))
    completed_lessons.each do |lesson|
      student.lesson_progresses.create!(
        lesson: lesson,
        completed: true,
        completed_at: rand(enrollment.enrolled_at..Time.current),
        time_spent_seconds: rand(300..2400) # 5-40 minutes
      )
    end
  end
end

# Create some notifications
puts "Creating sample notifications..."
User.all.each do |user|
  next if user.admin?

  # Create welcome notification
  user.notifications.create!(
    title: "Welcome to GEMS LMS!",
    message: "Welcome to our learning management system. Start exploring courses and begin your learning journey!",
    notification_type: "general",
    sent_at: user.created_at + 1.hour,
    read: [ true, false ].sample
  )

  # Create a random notification
  if user.student?
    user.notifications.create!(
      title: "New Course Recommendation",
      message: "Based on your interests, we recommend checking out our latest programming courses!",
      notification_type: "general",
      sent_at: rand(7.days).seconds.ago,
      read: [ true, false ].sample
    )
  end
end

# Create sample payments for demonstration
puts "Creating sample payments..."
students.first(3).each do |student|
  paid_courses = created_courses.select { |c| c.price > 0 }.sample(2)
  paid_courses.each do |course|
    status = [ 'completed', 'pending', 'failed' ].sample
    payment = student.payments.create!(
      course: course,
      amount: course.price,
      currency: 'KES',
      payment_method: 'mpesa',
      phone_number: "25470#{rand(1000000..9999999)}",
      transaction_id: "GEMS_#{Time.current.strftime('%Y%m%d_%H%M%S')}_#{SecureRandom.hex(4)}",
      status: status,
      mpesa_receipt_number: status == 'completed' ? "#{rand(100000000..999999999)}" : nil,
      completed_at: status == 'completed' ? rand(7.days).seconds.ago : nil,
      created_at: rand(30.days).seconds.ago
    )

    # Enroll student if payment completed
    if payment.status == 'completed'
      course.enrollments.create!(user: student, enrolled_at: payment.completed_at)
    end
  end
end

puts "Seed data creation completed!"
puts "Created:"
puts "- #{Category.count} categories"
puts "- #{User.admin.count} admin(s)"
puts "- #{User.instructor.count} instructor(s)"
puts "- #{User.student.count} student(s)"
puts "- #{Course.count} courses"
puts "- #{Section.count} sections"
puts "- #{Lesson.count} lessons"
puts "- #{Quiz.count} quizzes"
puts "- #{Assignment.count} assignments"
puts "- #{Enrollment.count} enrollments"
puts "- #{Notification.count} notifications"

puts "\nLogin credentials:"
puts "Admin: admin@gems-lms.com / password123"
puts "Instructor: john.doe@gems-lms.com / password123"
puts "Student: student1@gems-lms.com / password123"
