# Command O Conference App

A modern Rails 8 application for Omise's internal developer conference with real-time updates, custom magic link authentication, and mobile-first design.

## 🚀 Features

- **Magic Link Authentication** - Secure, passwordless login for company emails
- **Real-time Updates** - Live check-in status and feedback aggregation using Turbo Streams
- **Mobile-First Design** - Responsive interface optimized for all devices
- **Admin Dashboard** - Comprehensive analytics and attendee management
- **Session Management** - Conference agenda with speaker details and feedback
- **Theme Switching** - Dark/light mode with Omise branding
- **Real-time Notifications** - Live updates across all connected users

## 🛠 Tech Stack

- **Backend**: Rails 8.0.2.1, Ruby 3.3.8
- **Database**: PostgreSQL 14+
- **Frontend**: Turbo + Hotwire, TailwindCSS, Stimulus.js
- **Authentication**: Custom magic link system
- **Real-time**: Turbo Streams for live updates
- **Styling**: TailwindCSS with custom Omise branding

## 📋 Prerequisites

Before you begin, ensure you have the following installed:

- **Ruby 3.3.8** (recommended: use [rbenv](https://github.com/rbenv/rbenv) or [rvm](https://rvm.io/))
- **PostgreSQL 14+** 
- **Node.js 18+** (for asset compilation)
- **Git**

### Check Your Versions

```bash
ruby --version    # Should be 3.3.8
psql --version    # Should be 14+
node --version    # Should be 18+
```

## 🚀 Quick Start

### 1. Clone the Repository

```bash
git clone <repository-url>
cd event-command
```

### 2. Install Ruby Dependencies

```bash
# Install bundler if you don't have it
gem install bundler

# Install all gems
bundle install
```

### 3. Database Setup

#### Start PostgreSQL
```bash
# On macOS with Homebrew
brew services start postgresql

# On Ubuntu/Debian
sudo systemctl start postgresql

# On Windows (if using PostgreSQL installer)
# PostgreSQL should start automatically
```

#### Create and Setup Database
```bash
# Create the database
rails db:create

# Run migrations
rails db:migrate

# Seed with sample data
rails db:seed
```

### 4. Environment Configuration

Create a `.env` file in the project root (optional, for custom database settings):

```bash
# .env
DATABASE_USERNAME=postgres
DATABASE_PASSWORD=your_password
DATABASE_HOST=localhost
```

### 5. Start the Application

```bash
# Start the Rails server
rails server

# Or start with custom port
rails server -p 3001
```

The application will be available at `http://localhost:3000`

## 🗄 Database Configuration

### PostgreSQL Setup

#### macOS (Homebrew)
```bash
# Install PostgreSQL
brew install postgresql@14

# Start PostgreSQL
brew services start postgresql@14

# Create a database user (optional)
createuser -s postgres
```

#### Ubuntu/Debian
```bash
# Install PostgreSQL
sudo apt update
sudo apt install postgresql postgresql-contrib

# Start PostgreSQL
sudo systemctl start postgresql
sudo systemctl enable postgresql

# Create a database user
sudo -u postgres createuser -s $USER
```

#### Windows
1. Download PostgreSQL from [postgresql.org](https://www.postgresql.org/download/windows/)
2. Run the installer and follow the setup wizard
3. Remember the password you set for the `postgres` user

### Database Environment Variables

The application uses these environment variables for database configuration:

```bash
DATABASE_USERNAME=postgres    # Default: postgres
DATABASE_PASSWORD=            # Default: empty
DATABASE_HOST=localhost       # Default: localhost
```

## 👥 Sample Data

The application comes with seeded sample data including:

- **Admin User**: `admin@company.com` (admin privileges)
- **Speaker Users**: Sample speakers for conference sessions
- **Attendee Users**: Sample attendees for testing
- **Conference Sessions**: Sample sessions with realistic data
- **Feedback Data**: Sample feedback for testing analytics

### Access Sample Data

After running `rails db:seed`, you can:

1. **Login as Admin**: Use `admin@company.com` to access admin features
2. **Login as Attendee**: Use any `@company.com` email to test attendee features
3. **View Sessions**: Browse the conference agenda
4. **Test Feedback**: Submit feedback on completed sessions

## 🔧 Development

### Running Tests

```bash
# Run all tests
rails test

# Run specific test file
rails test test/controllers/sessions_controller_test.rb

# Run with coverage
COVERAGE=true rails test
```

### Code Quality

```bash
# Run RuboCop for code style
bundle exec rubocop

# Auto-fix RuboCop issues
bundle exec rubocop -a

# Run Brakeman for security
bundle exec brakeman
```

### Database Management

```bash
# Reset database (WARNING: deletes all data)
rails db:reset

# Rollback last migration
rails db:rollback

# Check database status
rails db:version
```

## 🎨 Styling & Assets

### TailwindCSS

The app uses TailwindCSS for styling with custom Omise branding:

```bash
# Watch for CSS changes
rails tailwindcss:watch

# Build CSS for production
rails tailwindcss:build
```

### Custom Branding

- **Primary Color**: Omise Teal (`#00D4AA`)
- **Dark Theme**: Default with light theme option
- **Typography**: Modern, clean fonts
- **Icons**: Heroicons for consistent iconography

## 📱 Mobile Development

The app is built mobile-first with responsive design:

- **Breakpoints**: `sm` (640px), `md` (768px), `lg` (1024px), `xl` (1280px)
- **Touch Targets**: Minimum 44px for mobile interaction
- **Progressive Enhancement**: Works without JavaScript

## 🔐 Authentication

### Magic Link System

The app uses a custom magic link authentication system:

1. **Email Validation**: Only `@company.com` domains allowed
2. **Token Generation**: 32-character secure random tokens
3. **Token Expiry**: 15-minute expiration for security
4. **Email Delivery**: Branded HTML emails with magic links

### Email Configuration

For development, emails are saved to `tmp/mails/` directory. For production, configure SMTP settings in `config/environments/production.rb`.

## 🚀 Deployment

### Environment Variables

Set these environment variables in production:

```bash
RAILS_MASTER_KEY=your_master_key
DATABASE_URL=postgresql://user:password@host:port/database
SMTP_HOST=your_smtp_host
SMTP_PORT=587
SMTP_USERNAME=your_email
SMTP_PASSWORD=your_password
```

### Database Migration

```bash
# Run migrations in production
RAILS_ENV=production rails db:migrate

# Seed production data (if needed)
RAILS_ENV=production rails db:seed
```

## 🐛 Troubleshooting

### Common Issues

#### Database Connection Error
```bash
# Check PostgreSQL is running
brew services list | grep postgresql

# Restart PostgreSQL
brew services restart postgresql@14
```

#### Bundle Install Issues
```bash
# Clear bundle cache
bundle clean --force

# Reinstall gems
bundle install --redownload
```

#### Asset Compilation Issues
```bash
# Clear asset cache
rails assets:clobber

# Rebuild assets
rails assets:precompile
```

#### Port Already in Use
```bash
# Kill process on port 3000
lsof -ti:3000 | xargs kill -9

# Or use different port
rails server -p 3001
```

### Getting Help

1. Check the Rails logs: `tail -f log/development.log`
2. Check PostgreSQL logs: `tail -f /usr/local/var/log/postgresql.log`
3. Verify all services are running: `brew services list`

## 📚 API Documentation

### Key Endpoints

- `GET /` - Login page
- `GET /agenda` - Conference agenda (attendee view)
- `GET /admin/dashboard` - Admin dashboard
- `POST /check_in` - Check in to conference
- `GET /sessions/:id` - Session details
- `POST /feedback/session/:id` - Submit session feedback

### Authentication Flow

1. User enters email on login page
2. System generates magic link token
3. Email sent with magic link
4. User clicks link to authenticate
5. Session created and user redirected to agenda

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature-name`
3. Make your changes
4. Run tests: `rails test`
5. Commit changes: `git commit -m "Add feature"`
6. Push to branch: `git push origin feature-name`
7. Submit a pull request

## 📄 License

This project is proprietary software for Omise internal use.

## 🆘 Support

For technical support or questions:

1. Check this README for common solutions
2. Review the Rails logs for error details
3. Contact the development team

---

**Happy Coding! 🚀**