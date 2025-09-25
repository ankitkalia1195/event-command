#!/bin/bash

echo "Setting up Face Recognition Service..."

# Navigate to the project directory
cd "$(dirname "$0")"

# Create Python virtual environment if it doesn't exist
if [ ! -d "python_services/venv" ]; then
    echo "Creating Python virtual environment..."
    python3 -m venv python_services/venv
fi

# Activate virtual environment
echo "Activating virtual environment..."
source python_services/venv/bin/activate

# Install Python dependencies
echo "Installing Python dependencies..."
pip install -r python_services/requirements.txt

echo "Setup complete!"
echo ""
echo "To start the face recognition service:"
echo "1. Activate the virtual environment: source python_services/venv/bin/activate"
echo "2. Start the service: python python_services/face_service/api.py"
echo "   OR: uvicorn python_services.face_service.api:app --reload --host 0.0.0.0 --port 8001"
echo ""
echo "The service will be available at: http://localhost:8001"
echo "Face login will be available at: http://localhost:3000/face_login"
