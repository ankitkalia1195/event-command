#!/bin/bash

echo "🧪 Running Event Command Controller Tests"
echo "=========================================="
echo ""

# Set up test database
echo "📊 Setting up test database..."
bundle exec rails db:test:prepare

echo ""
echo "🚀 Running all controller tests..."
echo ""

# Run the tests
bundle exec rails test test/controllers/

echo ""
echo "✅ Test run completed!"
echo ""
echo "To run specific test files:"
echo "  bundle exec rails test test/controllers/sessions_controller_test.rb"
echo "  bundle exec rails test test/controllers/feedback_controller_test.rb"
echo "  bundle exec rails test test/controllers/agenda_controller_test.rb"
echo "  bundle exec rails test test/controllers/admin/admin_controller_test.rb"
echo ""
echo "To run with verbose output:"
echo "  bundle exec rails test -v"
