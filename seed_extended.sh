#!/bin/bash

echo "🌱 Running extended seed data..."
echo "This will create 100 users, set lorrain@opn.ooo as admin, and generate comprehensive feedback data."
echo ""

# Run the extended seed
bundle exec rails db:seed:extended

echo ""
echo "✅ Extended seeding completed!"
echo "You can now:"
echo "- Login as admin: lorrain@opn.ooo"
echo "- Test with 100+ users and realistic feedback data"
echo "- View paginated attendee lists and recent feedback"
