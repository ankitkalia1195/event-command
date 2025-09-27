#!/bin/bash

echo "🎯 **SIMPLE Face Recognition Setup**"
echo "=================================="
echo ""
echo "✅ No heavy model downloads needed!"
echo "✅ Uses OpenCV built-in face detection"
echo "✅ Quick and lightweight"
echo ""

# Start face service in background
echo "1. Starting Face Recognition API..."
source python_services/venv/bin/activate
export PYTHONPATH="$PWD/python_services:$PYTHONPATH"
cd python_services
uvicorn face_service.api:app --host 0.0.0.0 --port 8001 &
FACE_PID=$!
cd ..

sleep 3

# Test face service
if curl -s http://localhost:8001/health | grep -q "ok"; then
    echo "   ✅ Face API running on http://localhost:8001"
else
    echo "   ❌ Face API failed to start"
    exit 1
fi

echo ""
echo "2. Starting Rails server..."
bin/rails server -p 3000 &
RAILS_PID=$!
sleep 3
echo "   ✅ Rails running on http://localhost:3000"

echo ""
echo "🎉 **Both services are running!**"
echo ""
echo "📋 **Next steps:**"
echo ""
echo "3. Create a test user:"
echo "   bin/rails console"
echo "   User.create!(name: 'Test', email: 'test@company.com', role: 'attendee')"
echo ""
echo "4. Add your face (replace with your photo path):"
echo "   ./encode_face.sh  ../../../../Users/voravit.s/Downloads/Harry.png"
echo ""
echo "5. Add encoding to database:"
echo "   bin/rails console"
echo "   user = User.find_by(email: 'test@company.com')"
echo "   user.face_encoding_data = File.read('face_encoding.json')"
echo "   user.save!"
echo ""
echo "6. Test face login:"
echo "   http://localhost:3000/face_login"
echo ""
echo "Press Ctrl+C to stop all services"

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
