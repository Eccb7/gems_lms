# GEMS LMS - Learning Management System

![GEMS LMS](https://img.shields.io/badge/Rails-8.0.2-red.svg)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-16+-blue.svg)
![TailwindCSS](https://img.shields.io/badge/TailwindCSS-v4-06B6D4.svg)
![License](https://img.shields.io/badge/License-MIT-green.svg)

A comprehensive, modern Learning Management System built with Ruby on Rails 8, featuring a beautiful responsive UI inspired by leading educational platforms like Lecturio. GEMS LMS provides a complete solution for online education with role-based access, course management, progress tracking, and analytics.

## 🚀 Features

### 👥 Multi-Role System
- **Students**: Browse courses, track progress, take quizzes, submit assignments
- **Instructors**: Create and manage courses, track student progress, grade assignments
- **Administrators**: System management, user oversight, analytics dashboard

### 📚 Course Management
- Rich course creation with sections and lessons
- Multiple lesson types: Video, Text, Quiz, Assignment
- Course approval workflow
- Category-based organization
- Search and filtering functionality
- Course progress tracking
- Difficulty levels (Beginner, Intermediate, Advanced)

### 🎯 Learning Features
- Interactive video lessons
- Rich text content with Action Text
- Quiz system with multiple question types
- Assignment submissions with file uploads
- Progress tracking and analytics
- Completion certificates
- Learning streaks and achievements

### 📊 Analytics & Reporting
- Student progress dashboards
- Instructor analytics
- Admin system-wide reports
- Course performance metrics
- User engagement tracking

### 🔐 Security & Authentication
- Devise authentication
- Role-based authorization with CanCanCan
- Secure file uploads with Active Storage
- CSRF protection
- Content Security Policy

### 💎 Modern UI/UX
- Responsive design with TailwindCSS
- Mobile-first approach
- Dark/light mode support
- Accessibility features
- Progressive Web App capabilities

## 🛠 Tech Stack

### Backend
- **Ruby on Rails 8.0.2** - Web framework
- **PostgreSQL** - Primary database
- **Solid Cache** - Database-backed caching
- **Solid Queue** - Background job processing
- **Solid Cable** - WebSocket connections

### Frontend
- **TailwindCSS v4** - Utility-first CSS framework
- **Stimulus** - JavaScript framework
- **Turbo** - SPA-like experience
- **Action Text** - Rich text editing
- **View Component** - Component-based architecture

### File Storage & Processing
- **Active Storage** - File uploads and storage
- **Image Processing** - Image resizing and optimization

### Background Jobs
- **Sidekiq** - Background job processing
- **Sidekiq-Cron** - Scheduled jobs

### Search & Analytics
- **pg_search** - Full-text search
- **Chartkick** - Charts and analytics
- **Groupdate** - Date grouping for analytics

### Development & Testing
- **Debug** - Debugging tools
- **Brakeman** - Security vulnerability scanner
- **RuboCop** - Code style enforcer
- **Capybara & Selenium** - Integration testing

## 📋 Prerequisites

Before you begin, ensure you have the following installed:

- **Ruby**: 3.3.0 or higher
- **Rails**: 8.0.2 or higher
- **PostgreSQL**: 14+
- **Node.js**: 18+ (for asset compilation)
- **Redis**: 6+ (for Sidekiq background jobs)
- **ImageMagick**: For image processing

## 🚀 Getting Started

### 1. Clone the Repository

```bash
git clone https://github.com/Eccb7/gems_lms.git
cd gems_lms
```

### 2. Install Dependencies

```bash
# Install Ruby gems
bundle install

# Install Node.js packages (if using npm)
npm install
```

### 3. Database Setup

#### For PostgreSQL (Production/Staging):

```bash
# Configure database credentials
cp config/database.yml.example config/database.yml
# Edit config/database.yml with your PostgreSQL credentials

# Create and migrate database
rails db:create
rails db:migrate
```

#### For SQLite3 (Development):

```bash
# If using SQLite3, update config/database.yml for development
rails db:create
rails db:migrate
```

### 4. Seed the Database

```bash
# Load sample data
rails db:seed
```

This will create:
- 6 course categories
- 1 admin user
- 3 instructor users
- 10 student users
- 7 sample courses with complete content
- Enrollments and progress data

### 5. Configure Environment Variables

Create a `.env` file or set the following environment variables:

```bash
# Database (if using PostgreSQL)
DATABASE_URL=postgresql://username:password@localhost/gems_lms_development

# Redis (for Sidekiq)
REDIS_URL=redis://localhost:6379/0

# Action Mailer (for emails)
SMTP_ADDRESS=smtp.gmail.com
SMTP_PORT=587
SMTP_USERNAME=your-email@gmail.com
SMTP_PASSWORD=your-app-password

# File Storage (for production)
AWS_ACCESS_KEY_ID=your-aws-key
AWS_SECRET_ACCESS_KEY=your-aws-secret
AWS_REGION=us-west-2
AWS_BUCKET=your-s3-bucket
```

### 6. Start the Application

```bash
# Start Rails server
rails server

# In a separate terminal, start Sidekiq for background jobs
bundle exec sidekiq

# In another terminal, start the asset pipeline (if needed)
bin/dev
```

Visit `http://localhost:3000` to access the application.

## 👥 Default Users

After seeding, you can log in with these default accounts:

### Admin User
- **Email**: admin@gems.com
- **Password**: password123
- **Role**: Administrator

### Instructor Users
- **Email**: instructor1@gems.com, instructor2@gems.com, instructor3@gems.com
- **Password**: password123
- **Role**: Instructor

### Student Users
- **Email**: student1@gems.com through student10@gems.com
- **Password**: password123
- **Role**: Student

## 📁 Project Structure

```
gems_lms/
├── app/
│   ├── controllers/
│   │   ├── admin/          # Admin panel controllers
│   │   ├── instructor/     # Instructor dashboard controllers
│   │   ├── student/        # Student dashboard controllers
│   │   └── concerns/       # Shared controller concerns
│   ├── models/
│   │   ├── concerns/       # Model concerns
│   │   └── ...            # ActiveRecord models
│   ├── views/
│   │   ├── admin/         # Admin panel views
│   │   ├── instructor/    # Instructor dashboard views
│   │   ├── student/       # Student dashboard views
│   │   ├── courses/       # Course catalog views
│   │   ├── categories/    # Category views
│   │   ├── devise/        # Authentication views
│   │   └── layouts/       # Application layouts
│   ├── services/          # Service objects
│   ├── jobs/             # Background jobs
│   └── assets/           # Stylesheets, JavaScript, images
├── config/
│   ├── routes.rb         # Application routes
│   ├── database.yml      # Database configuration
│   └── ...              # Other configuration files
├── db/
│   ├── migrate/          # Database migrations
│   └── seeds.rb          # Database seed file
└── ...
```

## 🎨 UI Components

The application features a comprehensive design system inspired by Lecturio:

### Navigation
- Responsive header with role-based navigation
- Breadcrumb navigation for deep pages
- Mobile-friendly hamburger menu

### Course Cards
- Engaging course preview cards
- Progress indicators
- Instructor information
- Rating and review displays

### Dashboards
- Role-specific dashboards (Admin, Instructor, Student)
- Analytics and progress charts
- Quick action panels
- Activity feeds

### Forms
- Modern, accessible form designs
- Real-time validation
- File upload interfaces
- Rich text editors

## 🔧 Configuration

### Action Text
Rich text editing is powered by Action Text with Trix editor:

```ruby
# Already configured in the application
# Rich text content available on:
# - Course descriptions
# - Lesson content
# - Assignment instructions
```

### File Uploads
Active Storage is configured for file uploads:

```ruby
# config/storage.yml
# Supports local storage (development) and S3 (production)
```

### Background Jobs
Sidekiq handles background processing:

```ruby
# config/schedule.rb
# Automated tasks like:
# - Sending notification emails
# - Generating reports
# - Cleaning up temporary files
```

## 🚢 Deployment

### Production Checklist

1. **Environment Setup**
   ```bash
   RAILS_ENV=production
   SECRET_KEY_BASE=your-secret-key
   ```

2. **Database Migration**
   ```bash
   rails db:migrate RAILS_ENV=production
   ```

3. **Asset Compilation**
   ```bash
   rails assets:precompile RAILS_ENV=production
   ```

4. **Start Services**
   ```bash
   # Web server (using Puma)
   bundle exec puma -C config/puma.rb

   # Background jobs
   bundle exec sidekiq -d -e production
   ```

### Docker Deployment
A Dockerfile is included for containerized deployment:

```bash
# Build image
docker build -t gems-lms .

# Run container
docker run -p 3000:3000 gems-lms
```

### Kamal Deployment
The application is configured for Kamal deployment:

```bash
# Deploy to production
kamal deploy
```

## 🧪 Testing

Run the test suite:

```bash
# Run all tests
rails test

# Run system tests
rails test:system

# Run security scan
brakeman

# Run code style check
rubocop
```

## 📈 Performance

### Caching Strategy
- Database-backed caching with Solid Cache
- Fragment caching for course listings
- Counter caches for performance metrics

### Database Optimization
- Proper indexing on frequently queried columns
- N+1 query prevention with includes/joins
- Database connection pooling

### Asset Optimization
- Image optimization with Active Storage variants
- CSS/JS minification in production
- CDN support for static assets

## 🔐 Security

### Authentication & Authorization
- Secure authentication with Devise
- Role-based access control with CanCanCan
- CSRF protection on all forms

### Data Protection
- SQL injection prevention with parameterized queries
- XSS protection with content security policy
- Secure file upload validation

### Security Headers
- Content Security Policy
- X-Frame-Options
- X-Content-Type-Options
- Strict-Transport-Security

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

### Development Setup

1. Fork the repository
2. Create a feature branch: `git checkout -b feature-name`
3. Make your changes
4. Add tests for new functionality
5. Run the test suite: `rails test`
6. Commit your changes: `git commit -m 'Add feature'`
7. Push to your fork: `git push origin feature-name`
8. Submit a pull request

### Code Style

We follow the Ruby Style Guide and use RuboCop for enforcement:

```bash
# Check code style
rubocop

# Auto-fix issues
rubocop -a
```

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Inspired by educational platforms like Lecturio, Udemy, and Coursera
- Built with Ruby on Rails and the amazing Ruby community
- UI components inspired by Tailwind UI and Headless UI
- Icons from Heroicons

## 📞 Support

- **Documentation**: [Wiki](https://github.com/your-username/gems_lms/wiki)
- **Issues**: [GitHub Issues](https://github.com/your-username/gems_lms/issues)
- **Discussions**: [GitHub Discussions](https://github.com/your-username/gems_lms/discussions)
- **Email**: support@gems-lms.com

## 🗺 Roadmap

### Version 2.0
- [ ] Mobile app (React Native)
- [ ] Advanced analytics dashboard
- [ ] AI-powered course recommendations
- [ ] Live streaming capabilities
- [ ] Advanced quiz types (code challenges, simulations)

### Version 1.5
- [ ] Payment integration (Stripe)
- [ ] Course certificates
- [ ] Discussion forums
- [ ] Email marketing integration
- [ ] Advanced reporting

### Version 1.1
- [ ] API documentation
- [ ] Webhook support
- [ ] Advanced search with Elasticsearch
- [ ] Multi-language support
- [ ] SCORM compliance

---

**GEMS LMS** - Empowering learners worldwide with quality education and innovative learning experiences.

Made with ❤️ by the GEMS team.
