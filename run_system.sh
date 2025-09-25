#!/bin/bash

# Complete setup and run script for Face Recognition System
echo "🎯 Face Recognition Login System Setup"
echo "======================================="

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Step 1: Setup Python environment
echo "1️⃣  Setting up Python environment..."
if [ ! -d "python_services/venv" ]; then
    echo "   Creating virtual environment..."
    python3 -m venv python_services/venv
fi

# Activate virtual environment
echo "   Activating virtual environment..."
source python_services/venv/bin/activate

# Install dependencies
echo "   Installing dependencies..."
pip install --upgrade pip
pip install -r python_services/requirements.txt

# Step 2: Check Rails environment  
echo ""
echo "2️⃣  Checking Rails environment..."
if ! command -v bundle &> /dev/null; then
    echo "❌ Bundler not found. Please install Ruby and Bundler first."
    exit 1
fi

# Step 3: Start services
echo ""
echo "3️⃣  Starting services..."

# Function to cleanup background processes
cleanup() {
    echo ""
    echo "🛑 Shutting down services..."
    if [ ! -z "$FACE_PID" ]; then
        kill $FACE_PID 2>/dev/null
    fi
    if [ ! -z "$RAILS_PID" ]; then  
        kill $RAILS_PID 2>/dev/null
    fi
    exit 0
}

# Set trap for cleanup
trap cleanup SIGINT SIGTERM

# Start Face Recognition Service
echo "   🐍 Starting Face Recognition Service..."
export PYTHONPATH="$SCRIPT_DIR/python_services:$PYTHONPATH"
cd python_services
uvicorn face_service.api:app --host 0.0.0.0 --port 8001 &
FACE_PID=$!
cd ..

# Wait a moment for the service to start
sleep 3

# Test the face service
echo "   🔍 Testing Face Recognition Service..."
if curl -s http://localhost:8001/health | grep -q "ok"; then
    echo "   ✅ Face Recognition Service is running"
else
    echo "   ❌ Face Recognition Service failed to start"
    cleanup
    exit 1
fi

# Start Rails server
echo "   🚂 Starting Rails server..."
bin/rails server -p 3000 &
RAILS_PID=$!

# Wait a moment for Rails to start
sleep 5

echo ""
echo "🎉 System is ready!"
echo ""
echo "📱 Services running:"
echo "   • Face Recognition API: http://localhost:8001"
echo "   • Rails Application: http://localhost:3000"
echo "   • Face Login: http://localhost:3000/face_login"
echo ""
echo "🔧 Next steps:"
echo "   1. Add face encodings for users (see instructions below)"
echo "   2. Visit http://localhost:3000/face_login to test"
echo ""
echo "💡 To add face encodings:"
echo "   python python_services/encode_sample.py /path/to/user_photo.jpg"
echo "   # Then in Rails console:"
echo "   user = User.find_by(email: 'user@company.com')"
echo "   user.face_encoding_data = File.read('face_encoding.json')"
echo "   user.save!"
echo ""
echo "Press Ctrl+C to stop all services"

# Wait for interrupt
wait
