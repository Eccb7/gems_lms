# Production Deployment Guide

## Prerequisites

Before deploying GEMS LMS to production, ensure you have:

1. **Server Requirements:**
   - Ubuntu 20.04+ or similar Linux distribution
   - Ruby 3.3.0+
   - PostgreSQL 14+
   - Redis 6+
   - Nginx (recommended)
   - SSL certificate

2. **External Services:**
   - Email service (SMTP or service like SendGrid)
   - File storage (AWS S3 or similar)
   - Domain name and DNS configuration

## Environment Setup

### 1. System Dependencies

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install dependencies
sudo apt install -y build-essential git curl
sudo apt install -y postgresql postgresql-contrib
sudo apt install -y redis-server
sudo apt install -y nginx
sudo apt install -y imagemagick

# Install Node.js
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs

# Install Ruby (using rbenv recommended)
curl -fsSL https://github.com/rbenv/rbenv-installer/raw/HEAD/bin/rbenv-installer | bash
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(rbenv init -)"' >> ~/.bashrc
source ~/.bashrc

rbenv install 3.3.0
rbenv global 3.3.0
gem install bundler rails
```

### 2. Database Setup

```bash
# Create database user
sudo -u postgres createuser -s gems_lms

# Set password for database user
sudo -u postgres psql -c "ALTER USER gems_lms PASSWORD 'your_secure_password';"

# Create production database
sudo -u postgres createdb -O gems_lms gems_lms_production
```

### 3. Application Deployment

```bash
# Clone repository
git clone https://github.com/your-username/gems_lms.git
cd gems_lms

# Install dependencies
bundle install --deployment --without development test
npm install --production

# Setup environment
cp .env.example .env.production
# Edit .env.production with production values

# Precompile assets
RAILS_ENV=production bundle exec rails assets:precompile

# Run migrations
RAILS_ENV=production bundle exec rails db:migrate

# Seed production data (optional)
RAILS_ENV=production bundle exec rails db:seed
```

### 4. Service Configuration

#### Systemd Service for Rails

Create `/etc/systemd/system/gems-lms.service`:

```ini
[Unit]
Description=GEMS LMS Rails Application
Requires=postgresql.service
After=postgresql.service

[Service]
Type=simple
User=deploy
WorkingDirectory=/home/deploy/gems_lms
ExecStart=/home/deploy/.rbenv/shims/bundle exec puma -C config/puma.rb
Restart=always
RestartSec=10
Environment=RAILS_ENV=production

[Install]
WantedBy=multi-user.target
```

#### Systemd Service for Sidekiq

Create `/etc/systemd/system/gems-lms-sidekiq.service`:

```ini
[Unit]
Description=GEMS LMS Sidekiq Background Jobs
Requires=redis-server.service
After=redis-server.service

[Service]
Type=simple
User=deploy
WorkingDirectory=/home/deploy/gems_lms
ExecStart=/home/deploy/.rbenv/shims/bundle exec sidekiq -e production
Restart=always
RestartSec=10
Environment=RAILS_ENV=production

[Install]
WantedBy=multi-user.target
```

#### Enable and start services

```bash
sudo systemctl daemon-reload
sudo systemctl enable gems-lms gems-lms-sidekiq
sudo systemctl start gems-lms gems-lms-sidekiq
```

### 5. Nginx Configuration

Create `/etc/nginx/sites-available/gems-lms`:

```nginx
upstream gems_lms {
    server unix:///home/deploy/gems_lms/tmp/sockets/puma.sock fail_timeout=0;
}

server {
    listen 80;
    server_name yourdomain.com www.yourdomain.com;
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name yourdomain.com www.yourdomain.com;

    root /home/deploy/gems_lms/public;

    # SSL Configuration
    ssl_certificate /path/to/your/certificate.crt;
    ssl_certificate_key /path/to/your/private.key;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-RSA-AES256-GCM-SHA512:DHE-RSA-AES256-GCM-SHA512:ECDHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES256-GCM-SHA384;
    ssl_prefer_server_ciphers off;

    # Security Headers
    add_header X-Frame-Options DENY;
    add_header X-Content-Type-Options nosniff;
    add_header X-XSS-Protection "1; mode=block";
    add_header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload";

    # Asset serving
    location ^~ /assets/ {
        gzip_static on;
        expires 1y;
        add_header Cache-Control public;
        add_header Last-Modified "";
        add_header ETag "";
        break;
    }

    # Main application
    try_files $uri/index.html $uri @gems_lms;

    location @gems_lms {
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header Host $http_host;
        proxy_redirect off;
        proxy_pass http://gems_lms;
    }

    error_page 500 502 503 504 /500.html;
    client_max_body_size 4G;
    keepalive_timeout 10;
}
```

Enable the site:
```bash
sudo ln -s /etc/nginx/sites-available/gems-lms /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

## Environment Variables for Production

Key environment variables for `.env.production`:

```bash
# Rails
RAILS_ENV=production
SECRET_KEY_BASE=your-very-long-secret-key
RAILS_SERVE_STATIC_FILES=true
RAILS_LOG_TO_STDOUT=true

# Database
DATABASE_URL=postgresql://gems_lms:password@localhost/gems_lms_production

# Redis
REDIS_URL=redis://localhost:6379/0

# Email
SMTP_ADDRESS=smtp.sendgrid.net
SMTP_PORT=587
SMTP_USERNAME=apikey
SMTP_PASSWORD=your-sendgrid-api-key

# File Storage
ACTIVE_STORAGE_SERVICE=amazon
AWS_ACCESS_KEY_ID=your-aws-key
AWS_SECRET_ACCESS_KEY=your-aws-secret
AWS_REGION=us-west-2
AWS_BUCKET=your-production-bucket

# Security
FORCE_SSL=true
HSTS_ENABLED=true

# Application
APP_HOST=yourdomain.com
PROTOCOL=https
```

## Monitoring and Maintenance

### Log Management

```bash
# View application logs
sudo journalctl -u gems-lms -f

# View Sidekiq logs
sudo journalctl -u gems-lms-sidekiq -f

# View Nginx logs
sudo tail -f /var/log/nginx/access.log
sudo tail -f /var/log/nginx/error.log
```

### Database Backup

Create automated backup script `/home/deploy/backup-db.sh`:

```bash
#!/bin/bash
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/home/deploy/backups"
mkdir -p $BACKUP_DIR

pg_dump gems_lms_production | gzip > $BACKUP_DIR/gems_lms_$DATE.sql.gz

# Keep only last 7 days of backups
find $BACKUP_DIR -name "gems_lms_*.sql.gz" -mtime +7 -delete
```

Add to crontab for daily backups:
```bash
crontab -e
# Add this line:
0 2 * * * /home/deploy/backup-db.sh
```

### Application Updates

For zero-downtime deployments, consider using:
1. **Kamal** (included in Rails 8): For containerized deployments
2. **Capistrano**: For traditional deployments
3. **Docker**: For containerized applications

## Security Checklist

- [ ] SSL certificate installed and configured
- [ ] Database user has minimal required permissions
- [ ] Firewall configured to allow only necessary ports
- [ ] Regular security updates scheduled
- [ ] Application secrets properly secured
- [ ] File upload restrictions in place
- [ ] Rate limiting configured (consider Rack::Attack)
- [ ] Regular backups automated and tested
- [ ] Monitoring and alerting set up

## Performance Optimization

1. **Database Optimization:**
   - Enable query caching
   - Add database indexes for frequently queried columns
   - Use connection pooling

2. **Caching:**
   - Configure Redis for session storage
   - Enable fragment caching
   - Use CDN for static assets

3. **Application Optimization:**
   - Enable Gzip compression
   - Optimize images and assets
   - Use background jobs for heavy operations

For detailed monitoring, consider integrating:
- **Application Performance Monitoring**: New Relic, DataDog, or Scout
- **Error Tracking**: Sentry or Bugsnag
- **Uptime Monitoring**: Pingdom or UptimeRobot
