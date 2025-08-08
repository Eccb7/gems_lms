class CourseExportService
  def self.export_course(course)
    export_data = {
      course: {
        title: course.title,
        description: course.description,
        objectives: course.objectives,
        prerequisites: course.prerequisites,
        price: course.price,
        difficulty_level: course.difficulty_level,
        featured: course.featured,
        category_name: course.category.name,
        instructor_email: course.instructor.email
      },
      sections: course.sections.map do |section|
        {
          title: section.title,
          description: section.description,
          position: section.position,
          lessons: section.lessons.map do |lesson|
            {
              title: lesson.title,
              content: lesson.content,
              lesson_type: lesson.lesson_type,
              position: lesson.position,
              duration_minutes: lesson.duration_minutes,
              quiz: lesson.quiz ? export_quiz(lesson.quiz) : nil,
              assignments: lesson.assignments.map { |assignment| export_assignment(assignment) }
            }
          end
        }
      end
    }

    export_data.to_json
  end

  def self.import_course(json_data, instructor)
    data = JSON.parse(json_data)
    course_data = data['course']

    # Find or create category
    category = Category.find_or_create_by(name: course_data['category_name']) do |cat|
      cat.description = "Imported category"
      cat.active = true
    end

    # Create course
    course = Course.create!(
      title: course_data['title'],
      description: course_data['description'],
      objectives: course_data['objectives'],
      prerequisites: course_data['prerequisites'],
      price: course_data['price'],
      difficulty_level: course_data['difficulty_level'],
      featured: course_data['featured'],
      category: category,
      instructor: instructor,
      status: 'draft'
    )

    # Remove default section
    course.sections.destroy_all

    # Create sections and lessons
    data['sections'].each do |section_data|
      section = course.sections.create!(
        title: section_data['title'],
        description: section_data['description'],
        position: section_data['position']
      )

      section_data['lessons'].each do |lesson_data|
        lesson = section.lessons.create!(
          title: lesson_data['title'],
          content: lesson_data['content'],
          lesson_type: lesson_data['lesson_type'],
          position: lesson_data['position'],
          duration_minutes: lesson_data['duration_minutes']
        )

        # Import quiz if present
        if lesson_data['quiz']
          import_quiz(lesson, lesson_data['quiz'])
        end

        # Import assignments if present
        lesson_data['assignments'].each do |assignment_data|
          import_assignment(lesson, assignment_data)
        end
      end
    end

    course
  end

  private

  def self.export_quiz(quiz)
    {
      title: quiz.title,
      description: quiz.description,
      time_limit_minutes: quiz.time_limit_minutes,
      max_attempts: quiz.max_attempts,
      passing_score: quiz.passing_score,
      questions: quiz.quiz_questions.map do |question|
        {
          question_text: question.question_text,
          question_type: question.question_type,
          position: question.position,
          points: question.points,
          options: question.quiz_options.map do |option|
            {
              option_text: option.option_text,
              is_correct: option.is_correct,
              position: option.position
            }
          end
        }
      end
    }
  end

  def self.export_assignment(assignment)
    {
      title: assignment.title,
      description: assignment.description,
      due_date: assignment.due_date,
      max_points: assignment.max_points,
      submission_format: assignment.submission_format
    }
  end

  def self.import_quiz(lesson, quiz_data)
    quiz = lesson.create_quiz!(
      title: quiz_data['title'],
      description: quiz_data['description'],
      time_limit_minutes: quiz_data['time_limit_minutes'],
      max_attempts: quiz_data['max_attempts'],
      passing_score: quiz_data['passing_score']
    )

    quiz_data['questions'].each do |question_data|
      question = quiz.quiz_questions.create!(
        question_text: question_data['question_text'],
        question_type: question_data['question_type'],
        position: question_data['position'],
        points: question_data['points']
      )

      question_data['options'].each do |option_data|
        question.quiz_options.create!(
          option_text: option_data['option_text'],
          is_correct: option_data['is_correct'],
          position: option_data['position']
        )
      end
    end
  end

  def self.import_assignment(lesson, assignment_data)
    lesson.assignments.create!(
      title: assignment_data['title'],
      description: assignment_data['description'],
      due_date: Date.parse(assignment_data['due_date']),
      max_points: assignment_data['max_points'],
      submission_format: assignment_data['submission_format']
    )
  end
end
