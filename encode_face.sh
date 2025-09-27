#!/bin/bash

# Face Encoding Script Wrapper
# Ensures virtual environment is activated before running encode_sample.py

if [ $# -ne 1 ]; then
    echo "Usage: $0 <path_to_image>"
    echo "Example: $0 /path/to/face_photo.jpg"
    exit 1
fi

IMAGE_PATH="$1"

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Check if image exists
if [ ! -f "$IMAGE_PATH" ]; then
    echo "❌ Image file not found: $IMAGE_PATH"
    exit 1
fi

# Check if virtual environment exists
if [ ! -d "python_services/venv" ]; then
    echo "❌ Virtual environment not found!"
    echo "Run: ./setup_face_service.sh first"
    exit 1
fi

# Activate virtual environment
echo "📦 Activating virtual environment..."
source python_services/venv/bin/activate

# Check if face service is running
echo "🔍 Checking if Face Recognition API is running..."
if ! curl -s http://localhost:8001/health >/dev/null 2>&1; then
    echo "❌ Face Recognition API is not running!"
    echo "Start it with: ./start_face_service.sh"
    exit 1
fi

echo "✅ Face Recognition API is running"

# Run the encoding script
echo "🎯 Encoding face from: $IMAGE_PATH"
python python_services/encode_sample.py "$IMAGE_PATH"

if [ $? -eq 0 ] && [ -f "face_encoding.json" ]; then
    echo ""
    echo "🎉 Success! Face encoding saved to: face_encoding.json"
    echo ""
    echo "📋 Next steps:"
    echo "1. Add to database with Rails console:"
    echo "   bin/rails console"
    echo "   user = User.find_by(email: 'your@company.com')"
    echo "   user.face_encoding_data = File.read('face_encoding.json')"
    echo "   user.save!"
    echo ""
    echo "2. Test at: http://localhost:3000/face_login"
else
    echo ""
    echo "❌ Failed to generate face encoding"
    echo "Please check:"
    echo "• Photo has a clear, visible face"
    echo "• Good lighting in the photo"
    echo "• Face is not too small or too large"
    echo "• Face Recognition API is running"
fi
