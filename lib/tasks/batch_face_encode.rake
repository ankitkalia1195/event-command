# lib/tasks/batch_face_encode.rake (Enhanced Version)
namespace :faces do
  desc "Batch encode face photos with options"
  task :batch_encode, [ :photos_directory, :email_domain, :create_users ] => :environment do |task, args|
    photos_dir = args[:photos_directory] || Rails.root.join("face_photos")
    email_domain = args[:email_domain] || "company.com"
    create_users = args[:create_users] != "false"  # Default true

    puts "🔍 Configuration:"
    puts "   Photos directory: #{photos_dir}"
    puts "   Email domain: #{email_domain}"
    puts "   Create missing users: #{create_users ? 'Yes' : 'No'}"
    puts "=" * 50

    unless Dir.exist?(photos_dir)
      puts "❌ Directory not found: #{photos_dir}"
      exit 1
    end

    # Process photos...
    image_extensions = %w[.jpg .jpeg .png .gif .bmp]
    photo_files = Dir.glob(File.join(photos_dir, "*")).select do |file|
      image_extensions.include?(File.extname(file).downcase) && File.file?(file)
    end

    stats = { success: 0, failed: 0, skipped: 0, created_users: 0 }

    photo_files.each_with_index do |photo_path, index|
      filename = File.basename(photo_path, File.extname(photo_path))
      email = "#{filename}@#{email_domain}"

      puts "[#{index + 1}/#{photo_files.length}] #{File.basename(photo_path)} → #{email}"

      begin
        user = User.find_by(email: email)

        if !user && !create_users
          puts "   ⏭️  User not found and create_users=false. Skipping..."
          stats[:skipped] += 1
          next
        elsif !user && create_users
          # Fix: Remove password attributes - this system uses magic link auth
          user = User.create!(
            name: filename.gsub(/[._-]/, " ").titleize,
            email: email,
            role: "attendee"
          )
          puts "   👤 Created user: #{user.name}"
          stats[:created_users] += 1
        end

        if user.face_encoding_data.present?
          puts "   ⚠️  Already has encoding. Skipping..."
          stats[:skipped] += 1
          next
        end

        # Encode face
        result = encode_face_from_file(photo_path)

        if result[:success]
          user.update!(face_encoding_data: result[:encoding].to_json)
          puts "   ✅ Encoded successfully"
          stats[:success] += 1
        else
          puts "   ❌ Failed: #{result[:error]}"
          stats[:failed] += 1
        end

      rescue => e
        puts "   ❌ Error: #{e.message}"
        stats[:failed] += 1
      end
    end

    puts "\n📊 FINAL SUMMARY:"
    puts "   ✅ Successful: #{stats[:success]}"
    puts "   ❌ Failed: #{stats[:failed]}"
    puts "   ⏭️  Skipped: #{stats[:skipped]}"
    puts "   👤 Users created: #{stats[:created_users]}"
  end

  desc "Clear all face encodings from database"
  task clear_all: :environment do
    print "⚠️  Are you sure you want to clear ALL face encodings? (y/N): "
    confirmation = STDIN.gets.chomp.downcase

    if confirmation == "y" || confirmation == "yes"
      count = User.where.not(face_encoding_data: [ nil, "" ]).count
      User.update_all(face_encoding_data: nil)
      puts "✅ Cleared #{count} face encodings"
    else
      puts "❌ Operation cancelled"
    end
  end

  desc "Test face service connection"
  task test_service: :environment do
    puts "🔗 Testing connection to face service..."

    begin
      uri = URI.parse("#{ENV.fetch('FACE_SERVICE_URL', 'http://localhost:8001')}/health")
      response = Net::HTTP.get_response(uri)

      if response.code == "200"
        puts "✅ Face service is running and accessible"
      else
        puts "❌ Face service returned status: #{response.code}"
      end
    rescue => e
      puts "❌ Cannot connect to face service: #{e.message}"
      puts "💡 Make sure the Python service is running: python face_service/api.py"
    end
  end

 private

  def encode_face_from_file(file_path)
    begin
      # Read and encode image to base64
      image_data = File.read(file_path)
      base64_image = "data:image/#{File.extname(file_path)[1..]};base64,#{Base64.strict_encode64(image_data)}"

      # Call face recognition service
      result = FaceRecognitionService.encode_face(base64_image)

      if result[:success] && result[:encoding]
        {
          success: true,
          encoding: result[:encoding]
        }
      else
        {
          success: false,
          error: result[:error] || "Unknown encoding error"
        }
      end

    rescue => e
      {
        success: false,
        error: "File processing error: #{e.message}"
      }
    end
  end
end