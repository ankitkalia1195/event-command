# 📋 **Step-by-Step Face Recognition Setup Guide**

Follow these steps to set up and test face recognition authentication.

## **Prerequisites**
- Rails application running
- Photo of your face (JPG/PNG format)
- Terminal access

---

## **Step 1: Start the Services** 🚀

### Option A: Automated Setup
```bash
# Run the automated setup script
./setup_face_demo.sh
```

### Option B: Manual Setup
```bash
# 1. Start Face Recognition API
./start_face_service.sh

# 2. In another terminal, start Rails
bin/rails server -p 3000
```

**Verify services are running:**
- Face API: http://localhost:8001/health (should return `{"status":"ok"}`)
- Rails: http://localhost:3000 (should show login page)

---

## **Step 2: Create a Test User** 👤

```bash
# Create user via Rails console
bin/rails console

# In console:
user = User.create!(
  name: 'Test User',
  email: 'test@company.com',
  role: 'attendee'
)

puts "Created user: #{user.name} (ID: #{user.id})"
exit
```

**Or use the helper script:**
```bash
bin/rails runner create_sample_users.rb
```

---

## **Step 3: Prepare Your Face Photo** 📸

**Photo Requirements:**
- Clear, well-lit face photo
- Face should be centered and visible
- Good lighting (avoid shadows)
- JPG or PNG format
- Face not too small or too large in frame

**Example good photos:**
- Passport-style photo
- Profile picture
- Webcam selfie in good lighting

---

## **Step 4: Generate Face Encoding** 🔢

```bash
# Make sure Face API is running (http://localhost:8001)
# Generate encoding from your photo
python python_services/encode_sample.py "/path/to/your/photo.jpg"
```

**Expected output:**
```
Encoding face from: /path/to/your/photo.jpg
✓ Face encoding successful!
Encoding length: 128 dimensions
Sample encoding (first 10 values): [0.123, -0.456, ...]
Encoding saved to: face_encoding.json
```

**If it fails:**
- Check photo has a clear face
- Try better lighting
- Ensure face is not too small/large
- Try a different photo

---

## **Step 5: Add Encoding to Database** 💾

```bash
# Add the generated encoding to your user
bin/rails console

# In console:
user = User.find_by(email: 'test@company.com')
user.face_encoding_data = File.read('face_encoding.json')
user.save!

puts "✅ Face encoding added to #{user.name}"
puts "Encoding length: #{JSON.parse(user.face_encoding_data).length}"
exit
```

**Verify it worked:**
```bash
bin/rails runner "puts User.where.not(face_encoding_data: [nil, '']).count"
# Should output: 1 (or more if you have multiple users)
```

---

## **Step 6: Test Face Login** 🎯

### Access Face Login
1. **Go to:** http://localhost:3000
2. **Click:** "Login with Face Recognition" button
3. **Or directly:** http://localhost:3000/face_login

### Authentication Flow
1. **Allow camera access** when browser prompts
2. **Position your face** in the camera view
3. **Click:** "Authenticate with Face" button
4. **Wait for processing:**
   - "Capturing image..."
   - "Authenticating..."
5. **Success:** Redirects to agenda page
6. **Failure:** Shows error message

---

## **Step 7: Understanding the Flow** 🔄

### What Happens During Authentication:

1. **Frontend (JavaScript):**
   - Captures webcam frame
   - Converts to base64 image
   - Sends POST to `/face_authenticate`

2. **Rails Controller:**
   - Receives base64 image
   - Gets all users with face encodings
   - Calls Python Face API

3. **Python Face API:**
   - Decodes image
   - Detects face in image
   - Generates 128D encoding
   - Compares against all known encodings
   - Returns best match

4. **Rails Response:**
   - If match found: logs user in
   - If no match: returns error
   - Updates session

### Database Flow:
```
User Table:
├── id: 1
├── name: "Test User"  
├── email: "test@company.com"
└── face_encoding_data: "[0.123, -0.456, ...]" (128 numbers)
```

---

## **Troubleshooting** 🔧

### Common Issues:

#### "No face detected"
- **Solution:** Ensure good lighting, face clearly visible
- **Try:** Different angle, remove glasses, better lighting

#### "Face not recognized"  
- **Solution:** Check if encoding is saved correctly
- **Debug:** 
  ```bash
  bin/rails console
  user = User.find_by(email: 'test@company.com')
  puts user.face_encoding_data.present?
  puts JSON.parse(user.face_encoding_data).length rescue "Invalid JSON"
  ```

#### "Camera not accessible"
- **Solution:** Allow camera permissions in browser
- **Try:** Different browser, HTTPS in production

#### "Service error"
- **Check:** Face API is running (`curl http://localhost:8001/health`)
- **Restart:** `./start_face_service.sh`

### Debug Commands:
```bash
# Check services
curl http://localhost:8001/health
curl http://localhost:3000

# Check users with encodings
bin/rails runner "puts User.where.not(face_encoding_data: [nil, '']).pluck(:name, :email)"

# Test encoding manually
python python_services/encode_sample.py /path/to/photo.jpg
```

---

## **Adding More Users** 👥

For each additional user:

1. **Create user:**
   ```bash
   bin/rails console
   user = User.create!(name: 'John Doe', email: 'john@company.com', role: 'attendee')
   ```

2. **Generate encoding:**
   ```bash
   python python_services/encode_sample.py "/path/to/john_photo.jpg"
   ```

3. **Save to database:**
   ```bash
   bin/rails console
   user = User.find_by(email: 'john@company.com')
   user.face_encoding_data = File.read('face_encoding.json')
   user.save!
   ```

---

## **Production Considerations** 🏭

- **HTTPS required** for camera access
- **Set FACE_SERVICE_URL** environment variable
- **Deploy Python service** to cloud platform
- **Add rate limiting** and security measures
- **Consider liveness detection** for enhanced security

---

## **Quick Test Script** ⚡

Save this as `test_face_auth.rb`:

```ruby
#!/usr/bin/env ruby
# Test face authentication setup

puts "🔍 Testing Face Authentication Setup"
puts "=" * 40

# Check if services are running
require 'net/http'

begin
  response = Net::HTTP.get_response(URI('http://localhost:8001/health'))
  if response.code == '200'
    puts "✅ Face API is running"
  else
    puts "❌ Face API returned: #{response.code}"
  end
rescue => e
  puts "❌ Face API not accessible: #{e.message}"
end

begin
  response = Net::HTTP.get_response(URI('http://localhost:3000'))
  if response.code == '200'
    puts "✅ Rails server is running"
  else
    puts "❌ Rails server returned: #{response.code}"
  end
rescue => e
  puts "❌ Rails server not accessible: #{e.message}"
end

# Check database
require_relative 'config/environment'

users_with_faces = User.where.not(face_encoding_data: [nil, ''])
puts "👥 Users with face encodings: #{users_with_faces.count}"

users_with_faces.each do |user|
  encoding_length = JSON.parse(user.face_encoding_data).length rescue 0
  puts "   • #{user.name} (#{user.email}): #{encoding_length} dimensions"
end

if users_with_faces.count == 0
  puts "⚠️  No users have face encodings yet"
  puts "   Run: python python_services/encode_sample.py /path/to/photo.jpg"
end

puts "\n🎯 Ready to test at: http://localhost:3000/face_login"
```

Run with: `ruby test_face_auth.rb`

---

That's it! Your face recognition system is now set up and ready to use. The authentication flow will match your live camera image against stored face encodings and log you in automatically if a match is found.
