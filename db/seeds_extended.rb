# Extended seed file for more comprehensive data
# Run with: rails db:seed:extended

puts "🌱 Starting extended seeding..."

# Create admin user
admin = User.find_or_create_by!(email: 'lorrain@opn.ooo') do |user|
  user.name = 'Lorrain OPN'
  user.role = 'admin'
end

admin_ankit = User.find_or_create_by!(email: 'ankit@opn.ooo') do |user|
  user.name = 'Ankit OPN'
  user.role = 'admin'
end

puts "✅ Created admin: #{admin.email}"
puts "✅ Created admin: #{admin_ankit.email}"


# Create 100 random users
puts "👥 Creating 100 users..."
user_domains = [ 'gmail.com', 'yahoo.com', 'hotmail.com', 'outlook.com', 'company.com', 'example.com', 'test.com' ]
first_names = [ 'Alex', 'Jordan', 'Taylor', 'Casey', 'Morgan', 'Riley', 'Avery', 'Quinn', 'Sage', 'River', 'Phoenix', 'Blake', 'Cameron', 'Drew', 'Emery', 'Finley', 'Hayden', 'Jamie', 'Kendall', 'Logan', 'Parker', 'Reese', 'Sawyer', 'Skyler', 'Tatum', 'Valentine', 'Winter', 'Zion', 'Ari', 'Briar', 'Cedar', 'Dakota', 'Eden', 'Forest', 'Gray', 'Haven', 'Indigo', 'Jade', 'Kai', 'Lane', 'Meadow', 'Nova', 'Ocean', 'Peyton', 'Rain', 'Sky', 'Storm', 'Sunny', 'True', 'Willow', 'Zen', 'Ace', 'Blaze', 'Cruz', 'Dash', 'Echo', 'Fox', 'Ghost', 'Hawk', 'Iris', 'Jazz', 'Koda', 'Luna', 'Mystic', 'Nyx', 'Onyx', 'Poe', 'Raven', 'Sage', 'Titan', 'Vega', 'Wren', 'Xara', 'Yara', 'Zara', 'Aria', 'Bella', 'Cora', 'Demi', 'Eva', 'Faye', 'Gia', 'Hope', 'Ivy', 'Joy', 'Kira', 'Lila', 'Maya', 'Nina', 'Opal', 'Pia', 'Quinn', 'Ruby', 'Sia', 'Tara', 'Uma', 'Vera', 'Willa', 'Xara', 'Yuna', 'Zoe' ]
last_names = [ 'Smith', 'Johnson', 'Williams', 'Brown', 'Jones', 'Garcia', 'Miller', 'Davis', 'Rodriguez', 'Martinez', 'Hernandez', 'Lopez', 'Gonzalez', 'Wilson', 'Anderson', 'Thomas', 'Taylor', 'Moore', 'Jackson', 'Martin', 'Lee', 'Perez', 'Thompson', 'White', 'Harris', 'Sanchez', 'Clark', 'Ramirez', 'Lewis', 'Robinson', 'Walker', 'Young', 'Allen', 'King', 'Wright', 'Scott', 'Torres', 'Nguyen', 'Hill', 'Flores', 'Green', 'Adams', 'Nelson', 'Baker', 'Hall', 'Rivera', 'Campbell', 'Mitchell', 'Carter', 'Roberts', 'Gomez', 'Phillips', 'Evans', 'Turner', 'Diaz', 'Parker', 'Cruz', 'Edwards', 'Collins', 'Reyes', 'Stewart', 'Morris', 'Morales', 'Murphy', 'Cook', 'Rogers', 'Gutierrez', 'Ortiz', 'Morgan', 'Cooper', 'Peterson', 'Bailey', 'Reed', 'Kelly', 'Howard', 'Ramos', 'Kim', 'Cox', 'Ward', 'Richardson', 'Watson', 'Brooks', 'Chavez', 'Wood', 'James', 'Bennett', 'Gray', 'Mendoza', 'Ruiz', 'Hughes', 'Price', 'Alvarez', 'Castillo', 'Sanders', 'Patel', 'Myers', 'Long', 'Ross', 'Foster', 'Jimenez' ]

100.times do |i|
  first_name = first_names.sample
  last_name = last_names.sample
  domain = user_domains.sample
  email = "#{first_name.downcase}.#{last_name.downcase}.#{i+1}@#{domain}"

  user = User.find_or_create_by!(email: email) do |u|
    u.name = "#{first_name} #{last_name}"
    u.role = 'attendee'
    u.checked_in = [ true, false ].sample # Random check-in status
  end

  print "." if (i + 1) % 10 == 0
end

puts "\n✅ Created 100 users"

# Get all users for feedback creation
users = User.all
sessions = Session.all

# Create more diverse feedback data
puts "📝 Creating comprehensive feedback data..."

# Session feedbacks (more realistic distribution)
sessions.each do |session|
  next unless session.past? # Only for past sessions

  # Random number of feedbacks per session (60-90% of users)
  feedback_count = (users.count * (0.6 + rand * 0.3)).to_i
  selected_users = users.sample(feedback_count)

  selected_users.each do |user|
    # Skip if user already has feedback for this session
    next if user.feedbacks.exists?(session: session)

    # More realistic rating distribution (slight bias towards higher ratings)
    rating = case rand
    when 0..0.1 then 1
    when 0.1..0.2 then 2
    when 0.2..0.4 then 3
    when 0.4..0.7 then 4
    else 5
    end

    # Generate realistic comments
    comments = [
      "Great session! Very informative and well-structured.",
      "Excellent presentation. The speaker was engaging and knowledgeable.",
      "Good content but could use more practical examples.",
      "Very helpful session. Learned a lot of new concepts.",
      "The speaker was clear and the material was relevant to my work.",
      "Interesting topic but the pace was a bit too fast.",
      "Outstanding session! One of the best I've attended.",
      "Good overview of the subject matter. Would recommend.",
      "The session was okay but could be improved with more interaction.",
      "Fantastic presentation with great insights and practical applications.",
      "Very well organized and easy to follow.",
      "Good session overall, though some parts were a bit technical.",
      "Excellent delivery and content. Very engaging!",
      "The speaker did a great job explaining complex topics.",
      "Good session with valuable takeaways.",
      "Very informative and well-presented.",
      "The content was relevant and the speaker was knowledgeable.",
      "Great session! Would love to see more like this.",
      "Good presentation but could use more real-world examples.",
      "Excellent session with clear explanations and good pacing.",
      "Very helpful and well-structured presentation.",
      "Good content and delivery. Learned a lot.",
      "The session was informative and engaging.",
      "Great presentation with practical insights.",
      "Very good session overall. Well done!",
      "Excellent content and clear explanations.",
      "Good session with valuable information.",
      "The presentation was well-organized and informative.",
      "Great session! Very educational and engaging.",
      "Good content and good delivery. Recommended.",
      "Very informative session with great insights.",
      "Excellent presentation and very knowledgeable speaker.",
      "Good session overall with practical applications.",
      "Great content and clear explanations.",
      "Very helpful session with good pacing.",
      "Excellent delivery and very engaging content.",
      "Good session with valuable takeaways.",
      "The presentation was informative and well-structured.",
      "Great session! Learned a lot of useful information.",
      "Very good content and excellent delivery.",
      "Good session with clear explanations and good examples."
    ]

    comment = comments.sample
    # Sometimes add more detailed comments
    if rand < 0.3
      additional_thoughts = [
        " The Q&A session was particularly helpful.",
        " I especially liked the practical examples provided.",
        " The speaker was very responsive to questions.",
        " The materials provided were very useful.",
        " I would definitely recommend this session to others.",
        " The pacing was perfect for the content.",
        " The visual aids were very effective.",
        " This session exceeded my expectations.",
        " The speaker's expertise really showed through.",
        " I learned several things I can apply immediately."
      ]
      comment += additional_thoughts.sample
    end

    user.feedbacks.create!(
      session: session,
      rating: rating,
      comment: comment
    )
  end
end

puts "✅ Created session feedbacks"

# Overall event feedbacks (about 70% of users)
overall_feedback_count = (users.count * 0.7).to_i
selected_users = users.sample(overall_feedback_count)

selected_users.each do |user|
  # Skip if user already has overall feedback
  next if user.feedbacks.overall_feedback.exists?

  # Overall event ratings tend to be higher
  rating = case rand
  when 0..0.05 then 1
  when 0.05..0.15 then 2
  when 0.15..0.35 then 3
  when 0.35..0.65 then 4
  else 5
  end

  # Generate overall event comments
  overall_comments = [
    "Excellent conference overall! Great organization and content.",
    "Very well organized event with high-quality sessions.",
    "Outstanding conference experience. Would definitely attend again.",
    "Great event with excellent speakers and valuable content.",
    "Very professional and well-run conference.",
    "Excellent overall experience. Learned a lot and met great people.",
    "Outstanding conference with great networking opportunities.",
    "Very well organized and informative event.",
    "Great conference overall with excellent content and speakers.",
    "Excellent event with valuable insights and networking.",
    "Very professional conference with high-quality presentations.",
    "Outstanding overall experience. Highly recommended.",
    "Great conference with excellent organization and content.",
    "Very well run event with valuable sessions and networking.",
    "Excellent conference experience with great speakers.",
    "Outstanding event with professional organization and content.",
    "Great overall experience with valuable takeaways.",
    "Very well organized conference with excellent content.",
    "Excellent event with great speakers and networking opportunities.",
    "Outstanding conference with professional organization.",
    "Great conference overall with valuable insights and content.",
    "Very well run event with excellent sessions and speakers.",
    "Excellent conference experience with great organization.",
    "Outstanding event with valuable content and networking.",
    "Great conference with professional organization and speakers.",
    "Very well organized with excellent content and presentations.",
    "Excellent overall experience with valuable insights.",
    "Outstanding conference with great speakers and content.",
    "Great event with professional organization and valuable sessions.",
    "Very well run conference with excellent content and networking.",
    "Excellent conference experience with outstanding organization.",
    "Great overall event with valuable content and speakers.",
    "Very professional conference with excellent sessions.",
    "Outstanding conference with great organization and content.",
    "Excellent event with valuable insights and networking opportunities.",
    "Great conference with professional speakers and content.",
    "Very well organized event with excellent presentations.",
    "Outstanding overall experience with valuable takeaways.",
    "Excellent conference with great organization and speakers.",
    "Great event with professional content and networking opportunities."
  ]

  comment = overall_comments.sample
  # Sometimes add more detailed feedback
  if rand < 0.4
    additional_feedback = [
      " The venue was excellent and the facilities were top-notch.",
      " The networking opportunities were fantastic.",
      " The food and refreshments were great.",
      " The registration process was smooth and efficient.",
      " The event app was very helpful and user-friendly.",
      " The staff was very helpful and professional.",
      " The schedule was well-planned and easy to follow.",
      " The technology setup was excellent throughout.",
      " The overall atmosphere was very positive and engaging.",
      " The follow-up materials were very comprehensive.",
      " The diversity of topics covered was impressive.",
      " The quality of speakers was consistently high.",
      " The interactive elements were very engaging.",
      " The overall value for money was excellent.",
      " The event exceeded my expectations in every way.",
      " The organization was flawless from start to finish.",
      " The content was relevant and up-to-date.",
      " The networking breaks were well-timed and effective.",
      " The overall experience was very professional.",
      " The event was well worth the time and investment."
    ]
    comment += additional_feedback.sample
  end

  user.feedbacks.create!(
    session: nil, # Overall event feedback
    rating: rating,
    comment: comment
  )
end

puts "✅ Created overall event feedbacks"

# Update some statistics
total_users = User.count
checked_in_users = User.checked_in.count
total_feedbacks = Feedback.count
session_feedbacks = Feedback.session_feedback.count
overall_feedbacks = Feedback.overall_feedback.count

puts "\n📊 Extended seeding completed!"
puts "👥 Total users: #{total_users}"
puts "✅ Checked-in users: #{checked_in_users}"
puts "📝 Total feedbacks: #{total_feedbacks}"
puts "🎯 Session feedbacks: #{session_feedbacks}"
puts "🌟 Overall feedbacks: #{overall_feedbacks}"
puts "📈 Check-in rate: #{(checked_in_users.to_f / total_users * 100).round(1)}%"
puts "💬 Feedback rate: #{(total_feedbacks.to_f / total_users * 100).round(1)}%"
