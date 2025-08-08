# Contributing to GEMS LMS

We love your input! We want to make contributing to GEMS LMS as easy and transparent as possible, whether it's:

- Reporting a bug
- Discussing the current state of the code
- Submitting a fix
- Proposing new features
- Becoming a maintainer

## 🚀 Development Process

We use GitHub to host code, to track issues and feature requests, as well as accept pull requests.

### Pull Requests Welcome

Pull requests are the best way to propose changes to the codebase. We actively welcome your pull requests:

1. Fork the repo and create your branch from `main`.
2. If you've added code that should be tested, add tests.
3. If you've changed APIs, update the documentation.
4. Ensure the test suite passes.
5. Make sure your code lints.
6. Issue that pull request!

## 🐛 Report Bugs Using GitHub Issues

We use GitHub issues to track public bugs. Report a bug by [opening a new issue](https://github.com/your-username/gems_lms/issues/new).

**Great Bug Reports** tend to have:

- A quick summary and/or background
- Steps to reproduce
  - Be specific!
  - Give sample code if you can
- What you expected would happen
- What actually happens
- Notes (possibly including why you think this might be happening, or stuff you tried that didn't work)

## 🛠 Development Setup

### Prerequisites

- Ruby 3.3.0+
- Rails 8.0.2+
- PostgreSQL 14+ (or SQLite3 for development)
- Node.js 18+
- Redis 6+
- ImageMagick

### Local Development

1. **Clone your fork:**
   ```bash
   git clone https://github.com/your-username/gems_lms.git
   cd gems_lms
   ```

2. **Install dependencies:**
   ```bash
   bundle install
   npm install
   ```

3. **Setup database:**
   ```bash
   rails db:create
   rails db:migrate
   rails db:seed
   ```

4. **Start the application:**
   ```bash
   # Terminal 1: Rails server
   rails server
   
   # Terminal 2: Background jobs
   bundle exec sidekiq
   
   # Terminal 3: Asset compilation (if needed)
   bin/dev
   ```

5. **Run tests:**
   ```bash
   rails test
   rails test:system
   ```

## 📝 Coding Standards

### Ruby Style Guide

We follow the [Ruby Style Guide](https://rubystyle.guide/) and use RuboCop for enforcement.

```bash
# Check code style
rubocop

# Auto-fix issues where possible
rubocop -a
```

### Key Conventions

#### Models
- Use meaningful model names (singular)
- Include comprehensive validations
- Add proper associations with dependent options
- Use scopes for common queries
- Include documentation for complex methods

```ruby
class Course < ApplicationRecord
  # Associations
  belongs_to :instructor, class_name: 'User'
  belongs_to :category
  has_many :sections, dependent: :destroy
  
  # Validations
  validates :title, presence: true, length: { minimum: 5, maximum: 100 }
  validates :description, presence: true
  validates :difficulty, inclusion: { in: %w[beginner intermediate advanced] }
  
  # Scopes
  scope :published, -> { where(status: 'published') }
  scope :by_difficulty, ->(level) { where(difficulty: level) }
  
  # Methods
  def enrollment_count
    enrollments.count
  end
end
```

#### Controllers
- Keep controllers thin - business logic belongs in services or models
- Use strong parameters
- Handle errors gracefully
- Use consistent response formats

```ruby
class CoursesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_course, only: [:show, :edit, :update, :destroy]
  
  def index
    @courses = CourseSearchService.new(search_params).call
                                 .includes(:instructor, :category)
                                 .page(params[:page])
  end
  
  private
  
  def set_course
    @course = Course.find(params[:id])
  end
  
  def course_params
    params.require(:course).permit(:title, :description, :difficulty, :category_id)
  end
  
  def search_params
    params.permit(:search, :category, :difficulty, :sort)
  end
end
```

#### Views
- Use semantic HTML
- Follow accessibility guidelines
- Use TailwindCSS classes consistently
- Create reusable components with ViewComponent
- Include proper alt text for images

```erb
<div class="bg-white rounded-lg shadow-md overflow-hidden hover:shadow-lg transition-shadow">
  <%= image_tag course.thumbnail, 
      alt: "#{course.title} course thumbnail",
      class: "w-full h-48 object-cover" %>
  
  <div class="p-6">
    <h3 class="text-xl font-semibold text-gray-900 mb-2">
      <%= course.title %>
    </h3>
    <p class="text-gray-600 mb-4">
      <%= truncate(course.description, length: 120) %>
    </p>
  </div>
</div>
```

#### Services
- Use service objects for complex business logic
- Keep methods focused and single-purpose
- Return consistent result objects
- Handle errors appropriately

```ruby
class CourseEnrollmentService
  def initialize(user, course)
    @user = user
    @course = course
  end
  
  def call
    return error_result('Course is full') if course.full?
    return error_result('Already enrolled') if user.enrolled_in?(course)
    
    enrollment = create_enrollment
    
    if enrollment.persisted?
      send_welcome_email
      success_result(enrollment)
    else
      error_result(enrollment.errors.full_messages.join(', '))
    end
  end
  
  private
  
  attr_reader :user, :course
  
  def create_enrollment
    user.enrollments.create(course: course, enrolled_at: Time.current)
  end
  
  def send_welcome_email
    CourseMailer.welcome_email(user, course).deliver_later
  end
  
  def success_result(data)
    { success: true, data: data }
  end
  
  def error_result(message)
    { success: false, error: message }
  end
end
```

### Testing Standards

#### Model Tests
```ruby
require 'test_helper'

class CourseTest < ActiveSupport::TestCase
  test 'should not save course without title' do
    course = courses(:one)
    course.title = nil
    assert_not course.save
  end
  
  test 'should calculate correct enrollment count' do
    course = courses(:ruby_basics)
    assert_equal 5, course.enrollment_count
  end
end
```

#### System Tests
```ruby
require 'application_system_test_case'

class CoursesTest < ApplicationSystemTestCase
  test 'visiting the courses index' do
    visit courses_path
    
    assert_selector 'h1', text: 'Courses'
    assert_selector '.course-card', count: 3
  end
  
  test 'searching for courses' do
    visit courses_path
    
    fill_in 'Search', with: 'Ruby'
    click_on 'Search'
    
    assert_selector '.course-card', count: 2
    assert_text 'Ruby Basics'
  end
end
```

## 🎨 UI/UX Guidelines

### Design Principles

1. **Accessibility First**: All components must be accessible
2. **Mobile First**: Design for mobile, enhance for desktop
3. **Consistency**: Use the established design system
4. **Performance**: Optimize for fast loading
5. **User-Centered**: Focus on user experience over aesthetics

### TailwindCSS Usage

#### Color Palette
```css
/* Primary colors */
.text-primary { @apply text-blue-600; }
.bg-primary { @apply bg-blue-600; }

/* Secondary colors */
.text-secondary { @apply text-gray-600; }
.bg-secondary { @apply bg-gray-100; }

/* Success, warning, error */
.text-success { @apply text-green-600; }
.text-warning { @apply text-yellow-600; }
.text-error { @apply text-red-600; }
```

#### Component Classes
```css
/* Buttons */
.btn-primary { @apply bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 transition-colors; }
.btn-secondary { @apply bg-gray-200 text-gray-800 px-4 py-2 rounded-lg hover:bg-gray-300 transition-colors; }

/* Cards */
.card { @apply bg-white rounded-lg shadow-md p-6; }
.card-hover { @apply hover:shadow-lg transition-shadow; }

/* Forms */
.form-input { @apply block w-full px-3 py-2 border border-gray-300 rounded-md focus:ring-blue-500 focus:border-blue-500; }
.form-label { @apply block text-sm font-medium text-gray-700 mb-2; }
```

### Component Structure

When creating new components, follow this structure:

```erb
<!-- app/components/course_card_component.html.erb -->
<div class="course-card bg-white rounded-lg shadow-md overflow-hidden hover:shadow-lg transition-shadow"
     data-testid="course-card-<%= course.id %>">
  
  <!-- Image section -->
  <div class="relative">
    <%= image_tag course.thumbnail, 
        alt: "#{course.title} course thumbnail",
        class: "w-full h-48 object-cover" %>
    
    <!-- Difficulty badge -->
    <div class="absolute top-2 right-2">
      <span class="px-2 py-1 text-xs font-medium bg-white bg-opacity-90 rounded-full">
        <%= course.difficulty.humanize %>
      </span>
    </div>
  </div>
  
  <!-- Content section -->
  <div class="p-6">
    <div class="flex items-center mb-2">
      <span class="text-sm text-gray-500"><%= course.category.name %></span>
    </div>
    
    <h3 class="text-xl font-semibold text-gray-900 mb-2">
      <%= link_to course.title, course_path(course), 
          class: "hover:text-blue-600 transition-colors" %>
    </h3>
    
    <p class="text-gray-600 mb-4">
      <%= truncate(course.description, length: 120) %>
    </p>
    
    <!-- Footer -->
    <div class="flex items-center justify-between">
      <div class="flex items-center">
        <%= image_tag course.instructor.avatar, 
            alt: course.instructor.name,
            class: "w-8 h-8 rounded-full mr-2" %>
        <span class="text-sm text-gray-700"><%= course.instructor.name %></span>
      </div>
      
      <div class="text-right">
        <div class="text-lg font-bold text-gray-900">
          <%= number_to_currency(course.price) %>
        </div>
      </div>
    </div>
  </div>
</div>
```

## 🧪 Testing Guidelines

### Test Coverage

We aim for high test coverage, especially for:
- Business logic in models and services
- Controller actions
- Critical user flows

### Test Types

1. **Unit Tests**: Test individual methods and classes
2. **Integration Tests**: Test how components work together
3. **System Tests**: Test complete user workflows
4. **Performance Tests**: Test application performance

### Writing Good Tests

```ruby
# Good: Descriptive test name
test 'should enroll student when course has available spots' do
  # Clear setup
  course = courses(:ruby_basics)
  student = users(:john_student)
  
  # Action
  result = CourseEnrollmentService.new(student, course).call
  
  # Assertions
  assert result[:success]
  assert student.enrolled_in?(course)
  assert_equal course.enrollments.count, 1
end

# Good: Test edge cases
test 'should not enroll student when course is full' do
  course = courses(:full_course)
  student = users(:jane_student)
  
  result = CourseEnrollmentService.new(student, course).call
  
  assert_not result[:success]
  assert_equal 'Course is full', result[:error]
end
```

## 📚 Documentation

### Code Documentation

- Use meaningful variable and method names
- Add comments for complex business logic
- Document public APIs with YARD
- Keep README.md up to date

### API Documentation

When adding new API endpoints, document them:

```ruby
# @route GET /api/v1/courses
# @param [String] search Optional search query
# @param [String] category Optional category filter
# @param [Integer] page Page number for pagination
# @return [Array<Course>] List of courses matching criteria
def index
  # Implementation
end
```

## 🔒 Security Considerations

### Authentication & Authorization

- Always use `authenticate_user!` before actions that require login
- Check authorization with CanCanCan abilities
- Use strong parameters in controllers
- Validate and sanitize user input

### Data Protection

- Never log sensitive information
- Use HTTPS in production
- Implement proper CSRF protection
- Validate file uploads

### Common Security Issues to Avoid

1. **SQL Injection**: Use parameterized queries
2. **XSS**: Escape user input in views
3. **Mass Assignment**: Use strong parameters
4. **Insecure Direct Object References**: Check authorization
5. **Session Management**: Use secure session configuration

## 🚀 Performance Guidelines

### Database Optimization

- Use proper database indexes
- Avoid N+1 queries with `includes`
- Use counter caches for frequently accessed counts
- Implement pagination for large datasets

### Frontend Performance

- Optimize images with Active Storage variants
- Use lazy loading for images
- Minimize JavaScript bundle size
- Implement proper caching strategies

### Monitoring

- Use application performance monitoring
- Monitor database query performance
- Track user behavior and errors
- Set up alerts for critical issues

## 📋 Pull Request Process

### Before Submitting

1. **Run the test suite**: `rails test`
2. **Run system tests**: `rails test:system`
3. **Check code style**: `rubocop`
4. **Run security scan**: `brakeman`
5. **Update documentation** if needed

### PR Template

When submitting a PR, please include:

- **Description**: What does this PR do?
- **Motivation**: Why is this change needed?
- **Testing**: How was this tested?
- **Screenshots**: For UI changes
- **Breaking Changes**: Any breaking changes?

### Example PR Description

```markdown
## Description
Adds course search functionality with filters for category and difficulty level.

## Motivation
Users need to be able to find courses quickly without browsing through all available courses.

## Changes
- Added CourseSearchService for handling search logic
- Updated courses controller to use search service
- Added search form to courses index page
- Added tests for search functionality

## Testing
- Added unit tests for CourseSearchService
- Added system tests for search UI
- Manually tested search with various queries

## Screenshots
[Include screenshots of the search interface]

## Breaking Changes
None
```

## 🤝 Code Review Guidelines

### As a Reviewer

- **Be constructive**: Provide specific, actionable feedback
- **Be thorough**: Check logic, security, performance, and style
- **Be timely**: Review PRs within 24-48 hours
- **Be respectful**: Remember there's a human behind the code

### Review Checklist

- [ ] Code follows style guidelines
- [ ] Tests are included and passing
- [ ] Documentation is updated
- [ ] No security vulnerabilities
- [ ] Performance considerations addressed
- [ ] Accessibility guidelines followed

## 🏷 Issue Labels

We use labels to categorize issues:

- `bug`: Something isn't working
- `enhancement`: New feature or request
- `documentation`: Improvements to documentation
- `good first issue`: Good for newcomers
- `help wanted`: Extra attention is needed
- `question`: Further information is requested
- `wontfix`: This will not be worked on

## 🎯 Roadmap Contributions

We welcome contributions to our roadmap items:

### High Priority
- Payment integration (Stripe)
- Advanced analytics dashboard
- Mobile responsive improvements
- Performance optimizations

### Medium Priority
- Discussion forums
- Advanced quiz types
- Email marketing integration
- API improvements

### Nice to Have
- Mobile app
- AI-powered recommendations
- Live streaming
- Multi-language support

## 💬 Communication

- **GitHub Issues**: For bugs and feature requests
- **GitHub Discussions**: For questions and general discussion
- **Pull Requests**: For code contributions
- **Email**: For security-related issues

## 📜 License

By contributing, you agree that your contributions will be licensed under the same license as the project (MIT License).

## 🙏 Recognition

Contributors will be recognized in:
- CONTRIBUTORS.md file
- GitHub contributor graphs
- Release notes for significant contributions

Thank you for contributing to GEMS LMS! 🎉
