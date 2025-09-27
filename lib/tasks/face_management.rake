namespace :face do
  desc "Add face photo to a user"
  task :add_photo, [ :email, :photo_path ] => :environment do |t, args|
    email = args[:email]
    photo_path = args[:photo_path]

    if email.blank? || photo_path.blank?
      puts "Usage: rails face:add_photo[user@example.com,/path/to/photo.jpg]"
      exit 1
    end

    user = User.find_by(email: email)
    unless user
      puts "User with email #{email} not found"
      exit 1
    end

    unless File.exist?(photo_path)
      puts "Photo file #{photo_path} not found"
      exit 1
    end

    begin
      user.face_photo.attach(io: File.open(photo_path), filename: File.basename(photo_path))
      puts "Photo attached to user #{user.name} (#{user.email})"

      if user.generate_face_encoding_from_photo
        puts "Face encoding generated successfully!"
      else
        puts "Failed to generate face encoding. Check the photo quality and try again."
      end
    rescue => e
      puts "Error: #{e.message}"
      exit 1
    end
  end

  desc "Process photos from photos/ folder (photos named as email addresses)"
  task process_photos: :environment do
    photos_dir = Rails.root.join("photos")

    unless Dir.exist?(photos_dir)
      puts "Photos directory not found at #{photos_dir}"
      puts "Please create the photos/ directory and add photos named as email addresses"
      exit 1
    end

    # Supported image extensions
    image_extensions = %w[.jpg .jpeg .png .gif .bmp .tiff .webp]

    # Find all image files in the photos directory
    photo_files = Dir.glob(File.join(photos_dir, "*")).select do |file|
      File.file?(file) && image_extensions.include?(File.extname(file).downcase)
    end

    if photo_files.empty?
      puts "No image files found in #{photos_dir}"
      puts "Supported formats: #{image_extensions.join(', ')}"
      exit 0
    end

    puts "Found #{photo_files.count} photo files to process"
    puts "=" * 50

    processed_count = 0
    error_count = 0

    photo_files.each do |photo_path|
      # Extract email from filename (remove extension)
      email = File.basename(photo_path, File.extname(photo_path))

      puts "Processing: #{email}"

      # Find or create user by email
      user = User.find_by(email: email)
      unless user
        # Create user automatically with name based on email
        name = email.split("@").first.gsub(/[._]/, " ").titleize
        user = User.create!(
          email: email,
          name: name,
          role: "attendee"
        )
        puts "  ✓ Created new user: #{user.name} (#{user.email})"
      else
        puts "  ✓ Found existing user: #{user.name} (#{user.email})"
      end

      begin
        # Attach photo to user
        user.face_photo.attach(io: File.open(photo_path), filename: File.basename(photo_path))
        puts "  ✓ Photo attached to #{user.name}"

        # Generate face encoding
        if user.generate_face_encoding_from_photo
          puts "  ✓ Face encoding generated successfully!"
          processed_count += 1
        else
          puts "  ✗ Failed to generate face encoding"
          error_count += 1
        end
      rescue => e
        puts "  ✗ Error: #{e.message}"
        error_count += 1
      end

      puts
    end

    puts "=" * 50
    puts "Processing complete!"
    puts "Successfully processed: #{processed_count}"
    puts "Errors: #{error_count}"

    if processed_count > 0
      puts "\nYou can now test face login at: http://localhost:3000/face_login"
    end
  end

  desc "Generate face encodings for all users with photos"
  task generate_encodings: :environment do
    users_with_photos = User.joins(:face_photo_attachment)

    if users_with_photos.empty?
      puts "No users with face photos found"
      exit 0
    end

    puts "Found #{users_with_photos.count} users with face photos"

    users_with_photos.each do |user|
      puts "Processing #{user.name} (#{user.email})..."

      if user.generate_face_encoding_from_photo
        puts "  ✓ Face encoding generated"
      else
        puts "  ✗ Failed to generate face encoding"
      end
    end

    puts "Done!"
  end

  desc "List users with face encodings"
  task list_encodings: :environment do
    users = User.with_face_encodings

    if users.empty?
      puts "No users with face encodings found"
    else
      puts "Users with face encodings:"
      users.each do |user|
        puts "  - #{user.name} (#{user.email})"
        puts "    Has photo: #{user.has_face_photo? ? 'Yes' : 'No'}"
        puts "    Encoding length: #{user.face_encoding&.length || 'N/A'}"
      end
    end
  end

  desc "Test face authentication"
  task test_auth: :environment do
    # Test with a dummy image
    test_image = "data:image/jpeg;base64,/9j/4AAQSkZJRgABAQAAAQABAAD/2wBDAAYEBQYFBAYGBQYHBwYIChAKCgkJChQODwwQFxQYGBcUFhYaHSUfGhsjHBYWICwgIyYnKSopGR8tMC0oMCUoKSj/2wBDAQcHBwoIChMKChMoGhYaKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCj/wAARCAABAAEDASIAAhEBAxEB/8QAFQABAQAAAAAAAAAAAAAAAAAAAAv/xAAUEAEAAAAAAAAAAAAAAAAAAAAA/8QAFQEBAQAAAAAAAAAAAAAAAAAAAAX/xAAUEQEAAAAAAAAAAAAAAAAAAAAA/9oADAMBAAIRAxEAPwCdABmX/9k="

    result = User.authenticate_by_face(test_image)
    puts "Face authentication test result:"
    puts "  Success: #{result[:success]}"
    puts "  Authenticated: #{result[:authenticated]}"
    puts "  Error: #{result[:error]}" if result[:error]
  end

  desc "Create users from emails (without photos)"
  task :create_users, [ :emails_file ] => :environment do |t, args|
    emails_file = args[:emails_file] || "emails.txt"

    unless File.exist?(emails_file)
      puts "Emails file not found: #{emails_file}"
      puts "Create a text file with one email per line"
      exit 1
    end

    emails = File.readlines(emails_file).map(&:strip).reject(&:blank?)

    if emails.empty?
      puts "No emails found in #{emails_file}"
      exit 0
    end

    puts "Creating users from #{emails.count} emails..."
    puts "=" * 50

    created_count = 0
    existing_count = 0

    emails.each do |email|
      user = User.find_by(email: email)

      if user
        puts "  ✓ User already exists: #{user.name} (#{user.email})"
        existing_count += 1
      else
        name = email.split("@").first.gsub(/[._]/, " ").titleize
        user = User.create!(
          email: email,
          name: name,
          role: "attendee"
        )
        puts "  ✓ Created: #{user.name} (#{user.email})"
        created_count += 1
      end
    end

    puts "=" * 50
    puts "User creation complete!"
    puts "Created: #{created_count}"
    puts "Already existed: #{existing_count}"
  end
end
