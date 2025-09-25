#!/usr/bin/env ruby

# Sample script to create test users for face recognition
# Run with: bin/rails runner create_sample_users.rb

puts "🎯 Creating sample users for face recognition testing..."

# Create sample users
users = [
  {
    name: "John Doe",
    email: "john.doe@company.com",
    role: "attendee"
  },
  {
    name: "Jane Smith",
    email: "jane.smith@company.com",
    role: "attendee"
  },
  {
    name: "Admin User",
    email: "admin@company.com",
    role: "admin"
  }
]

users.each do |user_data|
  user = User.find_or_create_by(email: user_data[:email]) do |u|
    u.name = user_data[:name]
    u.role = user_data[:role]
  end

  if user.persisted?
    puts "✅ Created/found user: #{user.name} (#{user.email})"
  else
    puts "❌ Failed to create user: #{user_data[:email]}"
    puts "   Errors: #{user.errors.full_messages.join(', ')}"
  end
end

puts ""
puts "📷 To add face encodings:"
puts "1. Take/get photos of the users"
puts "2. Start the face service: ./start_face_service.sh"
puts "3. Run: python python_services/encode_sample.py /path/to/photo.jpg"
puts "4. In Rails console:"
puts "   user = User.find_by(email: 'john.doe@company.com')"
puts "   user.face_encoding_data = File.read('face_encoding.json')"
puts "   user.save!"
puts ""
puts "🚀 Then test at: http://localhost:3000/face_login"
