# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Create admin user
admin = User.find_or_create_by!(email: 'admin@company.com') do |user|
  user.name = 'Conference Admin'
  user.role = 'admin'
  user.is_speaker = false
end

# Create sample speakers
speaker1 = User.find_or_create_by!(email: 'john.doe@company.com') do |user|
  user.name = 'John Doe'
  user.role = 'attendee'
  user.is_speaker = true
end

speaker2 = User.find_or_create_by!(email: 'jane.smith@company.com') do |user|
  user.name = 'Jane Smith'
  user.role = 'attendee'
  user.is_speaker = true
end

speaker3 = User.find_or_create_by!(email: 'mike.wilson@company.com') do |user|
  user.name = 'Mike Wilson'
  user.role = 'attendee'
  user.is_speaker = true
end

# Create sample attendees
attendee1 = User.find_or_create_by!(email: 'alice.johnson@company.com') do |user|
  user.name = 'Alice Johnson'
  user.role = 'attendee'
  user.is_speaker = false
end

attendee2 = User.find_or_create_by!(email: 'bob.brown@company.com') do |user|
  user.name = 'Bob Brown'
  user.role = 'attendee'
  user.is_speaker = false
end

# Create sample sessions with mixed timing for testing
# PAST SESSIONS (for feedback testing)
Session.find_or_create_by!(title: 'Welcome & Opening Keynote') do |session|
  session.abstract = 'Join us for the official opening of Command O Conference 2024. We\'ll cover the latest trends in software development, our company\'s technical achievements, and what to expect from this exciting day of learning and networking.'
  session.start_time = 2.hours.ago
  session.end_time = 1.hour.ago
  session.speaker = speaker1
end

Session.find_or_create_by!(title: 'Building Scalable APIs with Ruby on Rails') do |session|
  session.abstract = 'Learn best practices for building robust, scalable APIs using Ruby on Rails. We\'ll cover performance optimization, caching strategies, database design, and API versioning techniques used in production systems.'
  session.start_time = 3.hours.ago
  session.end_time = 2.hours.ago
  session.speaker = speaker2
end

# CURRENT SESSION (if any)
Session.find_or_create_by!(title: 'Modern Frontend Development with Hotwire') do |session|
  session.abstract = 'Discover how Hotwire is revolutionizing frontend development by bringing the simplicity of server-side rendering to modern web applications. We\'ll explore Turbo, Stimulus, and how they work together to create fast, interactive user experiences.'
  session.start_time = 30.minutes.ago
  session.end_time = 30.minutes.from_now
  session.speaker = speaker3
end

# UPCOMING SESSIONS
Session.find_or_create_by!(title: 'Database Performance & Optimization') do |session|
  session.abstract = 'Deep dive into PostgreSQL optimization techniques, query performance analysis, indexing strategies, and monitoring tools. Learn how to identify and resolve performance bottlenecks in your database layer.'
  session.start_time = 1.hour.from_now
  session.end_time = 2.hours.from_now
  session.speaker = speaker1
end

Session.find_or_create_by!(title: 'Closing Remarks & Networking') do |session|
  session.abstract = 'Wrap up the conference with key takeaways, upcoming initiatives, and networking opportunities. Connect with fellow developers and discuss the topics covered throughout the day.'
  session.start_time = 3.hours.from_now
  session.end_time = 4.hours.from_now
  session.speaker = speaker2
end

puts "Seeded database with:"
puts "- 1 admin user"
puts "- 3 speakers"
puts "- 2 attendees"
puts "- 5 conference sessions"
