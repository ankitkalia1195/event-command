# 🎯 Face Recognition Login System

A complete facial recognition authentication system integrated with your Rails event management application.

## 🚀 Quick Start

### 1. Run the Complete System
```bash
# This will set up everything and start both services
./run_system.sh
```

### 2. Create Sample Users (Optional)
```bash
bin/rails runner create_sample_users.rb
```

### 3. Add Face Photos and Generate Encodings

#### Option A: Batch Processing (Recommended)
```bash
# Start the face service (if not already running)
./start_face_service.sh

# Add photos to the photos/ directory named as email addresses
# Example: photos/john.doe@company.com.jpg
#          photos/jane.smith@company.com.png
#          photos/admin@company.com.jpeg

# Process all photos in the photos/ directory
# Users will be created automatically if they don't exist
rails face:process_photos
```

#### Option B: Individual Processing
```bash
# Add face photo to a specific user
rails face:add_photo[user@company.com,/path/to/user_photo.jpg]

# Or add photo manually and generate encoding separately
bin/rails console
> user = User.find_by(email: 'user@company.com')
> user.face_photo.attach(io: File.open('/path/to/photo.jpg'), filename: 'photo.jpg')
> user.generate_face_encoding_from_photo
```

### 4. Test Face Login
Visit: http://localhost:3000/face_login

## 🛠️ Manual Setup

If you prefer to run services separately:

### Python Face Service
```bash
# Setup (one time)
./setup_face_service.sh

# Start service
./start_face_service.sh
# OR
source python_services/venv/bin/activate
cd python_services
uvicorn face_service.api:app --reload --host 0.0.0.0 --port 8001
```

### Rails Application
```bash
bin/rails server -p 3000
```

## 📋 System Components

### Python Microservice (`python_services/face_service/`)
- **Endpoints:**
  - `GET /health` - Health check
  - `POST /encode` - Generate face encoding from base64 image
  - `POST /authenticate` - Authenticate face against known encodings
  - `POST /detect` - Face detection using Haar cascades

### Rails Integration
- **Routes:**
  - `GET /face_login` - Face login page with webcam
  - `POST /face_authenticate` - Face authentication endpoint
- **Service:** `FaceRecognitionService` - HTTP client for Python service
- **Model:** `User` with face encoding methods and Active Storage
- **Database:** `face_encoding_data` (text), `face_photo_url` (string)
- **Active Storage:** `face_photo` attachment for storing user photos

## 🔧 Configuration

### Environment Variables
- `FACE_SERVICE_URL` - Face service URL (default: http://localhost:8001)

### Face Recognition Settings
- **Tolerance:** 0.6 (adjustable in `FaceService.__init__()`)
- **Encoding:** 128-dimensional vectors
- **Library:** `face_recognition` (dlib-based)

## 📱 User Experience

1. **Login Page:** Users can choose email or face login
2. **Face Login:** Modern webcam interface with real-time feedback
3. **Authentication:** Matches against all stored face encodings
4. **Security:** Stores only mathematical encodings, not photos

## 🧪 Testing

### Health Check
```bash
curl http://localhost:8001/health
```

### Encode Test
```bash
curl -X POST http://localhost:8001/encode \
  -H "Content-Type: application/json" \
  -d '{"image_base64": "data:image/jpeg;base64,..."}'
```

## 🚨 Troubleshooting

### Common Issues

1. **ModuleNotFoundError: No module named 'face_service'**
   - Use `./start_face_service.sh` instead of direct uvicorn
   - Or set `PYTHONPATH="$PWD/python_services:$PYTHONPATH"`

2. **Camera not accessible**
   - Check browser permissions
   - Use HTTPS in production
   - Test different browsers

3. **Face not detected**
   - Ensure good lighting
   - Face should be clearly visible
   - Try different angles

4. **No matching face found**
   - Verify face encodings are stored in database
   - Check tolerance settings (default 0.6)
   - Ensure encoding was generated from clear photo

### Debugging
```bash
# Check if face service is running
curl http://localhost:8001/health

# Check Rails routes
bin/rails routes | grep face

# Check user encodings
bin/rails console
> User.where.not(face_encoding_data: [nil, ""]).count
```

## 🔐 Security Notes

- Face encodings are mathematical representations, not images
- Encodings cannot be reverse-engineered to recreate faces
- Consider adding liveness detection for production use
- Use HTTPS in production for webcam access

## 📊 Database Schema

```ruby
# Users table additions
add_column :users, :face_encoding_data, :text
add_column :users, :face_photo_url, :string

# Active Storage tables (automatically created)
# - active_storage_blobs
# - active_storage_attachments
# - active_storage_variant_records
```

## 🛠️ Management Commands

```bash
# Process all photos from photos/ directory (batch processing)
# Creates users automatically if they don't exist
rails face:process_photos

# Create users from email list (without photos)
rails face:create_users[emails.txt]

# Add face photo to a specific user
rails face:add_photo[user@example.com,/path/to/photo.jpg]

# Generate face encodings for all users with photos
rails face:generate_encodings

# List users with face encodings
rails face:list_encodings

# Test face authentication
rails face:test_auth
```

## 📁 File Structure

```
photos/                          # Batch processing directory
├── user1@company.com.jpg        # Photo named as email
├── user2@company.com.png        # Different formats supported
└── README.md                    # Instructions

python_services/                 # Face recognition service
├── face_service/
│   ├── api.py                   # FastAPI endpoints
│   └── face_service.py          # Face recognition logic
└── venv/                        # Python virtual environment
```

## 🎯 Next Steps

1. **Production Deployment:**
   - Deploy Python service to cloud platform
   - Set `FACE_SERVICE_URL` environment variable
   - Use HTTPS for webcam access

2. **Enhanced Security:**
   - Add liveness detection
   - Implement rate limiting
   - Add audit logging

3. **User Management:**
   - Add face enrollment interface
   - Allow users to update their face data
   - Provide fallback authentication methods

## 📞 Support

The system is ready to use! Users with stored face encodings can authenticate by simply looking at their camera.

Services:
- **Face Recognition API:** http://localhost:8001
- **Rails Application:** http://localhost:3000  
- **Face Login:** http://localhost:3000/face_login
