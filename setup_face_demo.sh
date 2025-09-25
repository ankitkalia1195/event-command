#!/bin/bash

# Step-by-step Face Recognition Setup Guide
echo "🎯 Face Recognition Setup - Step by Step"
echo "========================================"

echo ""
echo "Step 1: Starting Services..."
echo "1. Starting Face Recognition API..."

# Check if Python venv exists
if [ ! -d "python_services/venv" ]; then
    echo "   Creating Python virtual environment..."
    python3 -m venv python_services/venv
fi

# Activate and install dependencies
echo "   Installing dependencies..."
source python_services/venv/bin/activate
pip install -q -r python_services/requirements.txt

# Start face service in background
echo "   Starting Face Recognition API on port 8001..."
export PYTHONPATH="$PWD/python_services:$PYTHONPATH"
cd python_services
uvicorn face_service.api:app --host 0.0.0.0 --port 8001 &
FACE_PID=$!
cd ..

# Wait for service to start
sleep 3

# Test face service
if curl -s http://localhost:8001/health | grep -q "ok"; then
    echo "   ✅ Face Recognition API is running"
else
    echo "   ❌ Face Recognition API failed to start"
    exit 1
fi

echo ""
echo "2. Starting Rails server..."
bin/rails server -p 3000 &
RAILS_PID=$!

sleep 3
echo "   ✅ Rails server is running on port 3000"

echo ""
echo "🎉 Both services are now running!"
echo "   Face API: http://localhost:8001"
echo "   Rails App: http://localhost:3000"
echo ""
echo "📋 Next Steps:"
echo "   1. Create a test user (Step 2)"
echo "   2. Take/prepare a face photo (Step 3)"
echo "   3. Generate face encoding (Step 4)"
echo "   4. Add encoding to database (Step 5)"
echo "   5. Test face login (Step 6)"
echo ""
read -p "Press Enter when ready to continue to Step 2..."

echo ""
echo "Step 2: Creating Test User..."
bin/rails runner -e development << 'EOF'
user = User.find_or_create_by(email: 'test@company.com') do |u|
  u.name = 'Test User'
  u.role = 'attendee'
end

if user.persisted?
  puts "✅ Created test user: #{user.name} (#{user.email})"
else
  puts "❌ Failed to create user: #{user.errors.full_messages.join(', ')}"
end
EOF

echo ""
echo "📸 Step 3: Prepare Your Face Photo"
echo "   • Take a clear, well-lit photo of your face"
echo "   • Save it as JPG/PNG format"
echo "   • Face should be clearly visible and centered"
echo "   • Good lighting is important for accuracy"
echo ""
read -p "Enter the full path to your face photo: " PHOTO_PATH

if [ ! -f "$PHOTO_PATH" ]; then
    echo "❌ Photo not found at: $PHOTO_PATH"
    echo "Please check the path and try again"
    exit 1
fi

echo "✅ Photo found: $PHOTO_PATH"

echo ""
echo "Step 4: Generating Face Encoding..."
source python_services/venv/bin/activate
python python_services/encode_sample.py "$PHOTO_PATH"

if [ $? -eq 0 ] && [ -f "face_encoding.json" ]; then
    echo "✅ Face encoding generated successfully!"
else
    echo "❌ Failed to generate face encoding"
    echo "Please check:"
    echo "   • Photo has a clear, visible face"
    echo "   • Good lighting in the photo"
    echo "   • Face is not too small or too large"
    exit 1
fi

echo ""
echo "Step 5: Adding Encoding to Database..."
bin/rails runner -e development << 'EOF'
user = User.find_by(email: 'test@company.com')
if user && File.exist?('face_encoding.json')
  user.face_encoding_data = File.read('face_encoding.json')
  if user.save
    puts "✅ Face encoding added to user: #{user.name}"
    puts "   Encoding length: #{JSON.parse(user.face_encoding_data).length} dimensions"
  else
    puts "❌ Failed to save encoding: #{user.errors.full_messages.join(', ')}"
  end
else
  puts "❌ User not found or encoding file missing"
end
EOF

echo ""
echo "🎉 Setup Complete!"
echo ""
echo "Step 6: Test Face Login"
echo "   1. Open: http://localhost:3000"
echo "   2. Click 'Login with Face Recognition'"
echo "   3. Allow camera access when prompted"
echo "   4. Position your face in the camera"
echo "   5. Click 'Authenticate with Face'"
echo ""
echo "🔧 Troubleshooting:"
echo "   • Ensure good lighting"
echo "   • Face should be clearly visible"
echo "   • Try different angles if not recognized"
echo ""
echo "Press Ctrl+C to stop all services when done testing"

# Cleanup function
cleanup() {
    echo ""
    echo "🛑 Stopping services..."
    kill $FACE_PID 2>/dev/null
    kill $RAILS_PID 2>/dev/null
    exit 0
}

trap cleanup SIGINT SIGTERM
wait
