# Create natural healing categories
puts "Creating natural healing categories..."
categories = [
  { name: "Herbal Medicine", description: "Traditional plant-based healing and herbal remedies", color: "#059669" },
  { name: "Nutrition & Wellness", description: "Natural nutrition, superfoods, and dietary healing", color: "#10B981" },
  { name: "Aromatherapy", description: "Essential oils, aromatherapy practices, and natural scents", color: "#8B5CF6" },
  { name: "Holistic Health", description: "Mind-body-spirit wellness and integrative health approaches", color: "#3B82F6" },
  { name: "Natural Detox", description: "Natural cleansing, detoxification, and body purification", color: "#F59E0B" },
  { name: "Energy Healing", description: "Reiki, chakra balancing, and energy therapy practices", color: "#EC4899" },
  { name: "Herbal Consultation", description: "Professional herbal consulting and client assessment", color: "#EF4444" },
  { name: "Traditional Medicine", description: "Ancient healing traditions from around the world", color: "#6366F1" }
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

# Create natural healing instructors
puts "Creating natural healing instructor users..."
instructors = [
  {
    email: "dr.sarah.green@gems-lms.com",
    first_name: "Dr. Sarah",
    last_name: "Green",
    bio: "Certified Clinical Herbalist with 15+ years of experience in herbal medicine and natural healing. Author of 'Nature's Pharmacy' and founder of Green Wellness Institute."
  },
  {
    email: "maria.luna@gems-lms.com",
    first_name: "Maria",
    last_name: "Luna",
    bio: "Master Aromatherapist and Essential Oil Expert. Specializes in therapeutic-grade oils and holistic wellness practices with certifications from NAHA and AIA."
  },
  {
    email: "david.earth@gems-lms.com",
    first_name: "David",
    last_name: "Earth",
    bio: "Traditional Medicine Practitioner and Energy Healer. Trained in multiple indigenous healing traditions and certified Reiki Master with 20+ years of practice."
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

# Create natural healing courses
puts "Creating natural healing courses..."
herbal_medicine_category = Category.find_by(name: "Herbal Medicine")
nutrition_category = Category.find_by(name: "Nutrition & Wellness")
aromatherapy_category = Category.find_by(name: "Aromatherapy")
holistic_health_category = Category.find_by(name: "Holistic Health")

courses_data = [
  {
    title: "Complete Herbal Medicine Certification",
    description: "Master the ancient art of herbal healing with this comprehensive certification course. Learn to identify, harvest, and prepare medicinal plants for therapeutic use. Discover the healing properties of over 100 herbs and their applications.",
    objectives: "• Identify and harvest 100+ medicinal plants\n• Understand plant energetics and therapeutic actions\n• Prepare tinctures, teas, and herbal formulations\n• Create personalized herbal protocols\n• Practice ethical wildcrafting and sustainability\n• Gain certification in clinical herbalism",
    prerequisites: "No prior experience required. Passion for natural healing essential.",
    price: 297.00,
    category: herbal_medicine_category,
    instructor: created_instructors[0],
    difficulty_level: "beginner",
    featured: true,
    status: "published"
  },
  {
    title: "Essential Oils & Aromatherapy Mastery",
    description: "Dive deep into the therapeutic world of essential oils. Learn extraction methods, safety protocols, and therapeutic applications. Create custom blends for emotional, physical, and spiritual wellness.",
    objectives: "• Master 50+ essential oils and their properties\n• Understand extraction and quality testing\n• Learn safety protocols and dilution ratios\n• Create therapeutic blends for various conditions\n• Practice aromatic consultations\n• Develop signature product lines",
    prerequisites: "Open heart and desire to learn nature's aromatherapy.",
    price: 197.00,
    category: aromatherapy_category,
    instructor: created_instructors[1],
    difficulty_level: "intermediate",
    featured: true,
    status: "published"
  },
  {
    title: "Holistic Nutrition & Superfoods",
    description: "Transform your health through nature's pharmacy of foods. Learn the healing power of nutrition, superfoods, and dietary protocols. Discover how food can be your medicine in this comprehensive wellness course.",
    objectives: "• Understand nutritional healing principles\n• Master superfoods and their benefits\n• Design therapeutic meal plans\n• Learn food combining and energetics\n• Practice intuitive eating methods\n• Create personalized nutrition protocols",
    prerequisites: "Willingness to embrace food as medicine.",
    price: 147.00,
    category: nutrition_category,
    instructor: created_instructors[1],
    difficulty_level: "beginner",
    featured: false,
    status: "published"
  },
  {
    title: "Energy Healing & Reiki Mastery",
    description: "Awaken your natural healing abilities through energy work. Learn Reiki, chakra balancing, and various energy healing modalities. Connect with universal life force energy for healing self and others.",
    objectives: "• Master Reiki healing techniques\n• Understand chakra system and energy anatomy\n• Practice energy clearing and protection\n• Learn distance healing methods\n• Develop intuitive healing abilities\n• Receive Reiki attunements and certifications",
    prerequisites: "Open mind and heart to energy healing.",
    price: 247.00,
    category: holistic_health_category,
    instructor: created_instructors[2],
    difficulty_level: "intermediate",
    featured: true,
    status: "published"
  },
  {
    title: "Free Introduction to Natural Healing",
    description: "A completely free introduction to the world of natural healing. Discover the foundational principles of herbal medicine, holistic wellness, and nature's pharmacy.",
    objectives: "• Understand natural healing principles\n• Learn about medicinal plants basics\n• Introduction to holistic wellness\n• Basic herbal preparation methods\n• Safety in natural healing",
    prerequisites: "No prerequisites - perfect for natural healing beginners.",
    price: 0.0,
    category: herbal_medicine_category,
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
      transaction_date: status == 'completed' ? rand(7.days).seconds.ago : nil,
      created_at: rand(30.days).seconds.ago
    )

    # Enroll student if payment completed
    if payment.status == 'completed'
      course.enrollments.create!(user: student, enrolled_at: payment.transaction_date)
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
