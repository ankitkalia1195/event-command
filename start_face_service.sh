#!/bin/bash

# Face Recognition Service Startup Script
echo "🚀 Starting Face Recognition Service..."

# Get the directory of this script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Check if virtual environment exists
if [ ! -d "python_services/venv" ]; then
    echo "❌ Virtual environment not found!"
    echo "Run setup_face_service.sh first"
    exit 1
fi

# Activate virtual environment
echo "📦 Activating virtual environment..."
source python_services/venv/bin/activate

# Check if face_recognition is installed
python -c "import face_recognition" 2>/dev/null
if [ $? -ne 0 ]; then
    echo "⚠️  Installing face_recognition library..."
    pip install face_recognition
fi

# Set PYTHONPATH to include the python_services directory
export PYTHONPATH="$SCRIPT_DIR/python_services:$PYTHONPATH"

# Start the service
echo "🎯 Starting Face Recognition API on http://localhost:8001"
echo "💡 Use Ctrl+C to stop the service"
echo ""

cd python_services
uvicorn face_service.api:app --reload --host 0.0.0.0 --port 8001
