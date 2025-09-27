ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

class ActiveSupport::TestCase
  # Run tests in parallel with specified workers
  parallelize(workers: :number_of_processors)

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...

  # Helper method to create a user with default attributes
  def create_user(attributes = {})
    default_attributes = {
      name: "Test User",
      email: "test@example.com",
      role: "attendee"
    }
    User.create!(default_attributes.merge(attributes))
  end

  # Helper method to create a session with default attributes
  def create_session(attributes = {})
    default_attributes = {
      title: "Test Session",
      abstract: "Test Description",
      start_time: 1.hour.from_now,
      end_time: 2.hours.from_now,
      speaker: create_user
    }
    Session.create!(default_attributes.merge(attributes))
  end

  # Helper method to create feedback with default attributes
  def create_feedback(attributes = {})
    default_attributes = {
      rating: 5,
      comment: "Test feedback"
    }
    Feedback.create!(default_attributes.merge(attributes))
  end

  # Helper method to login a user in tests
  def login_user(user)
    post login_path, params: { email: user.email }
    follow_redirect!
  end

  # Helper method to create admin user
  def create_admin(attributes = {})
    default_attributes = {
      name: "Admin User",
      email: "admin@example.com",
      role: "admin"
    }
    User.create!(default_attributes.merge(attributes))
  end

  # Helper method to create past session for feedback testing
  def create_past_session(attributes = {})
    default_attributes = {
      title: "Past Session",
      abstract: "Past Description",
      start_time: 2.hours.ago,
      end_time: 1.hour.ago,
      speaker: create_user
    }
    Session.create!(default_attributes.merge(attributes))
  end

  # Helper method to create upcoming session
  def create_upcoming_session(attributes = {})
    default_attributes = {
      title: "Upcoming Session",
      abstract: "Upcoming Description",
      start_time: 1.hour.from_now,
      end_time: 2.hours.from_now,
      speaker: create_user
    }
    Session.create!(default_attributes.merge(attributes))
  end

  # Helper method to create current session
  def create_current_session(attributes = {})
    default_attributes = {
      title: "Current Session",
      abstract: "Current Description",
      start_time: 30.minutes.ago,
      end_time: 30.minutes.from_now,
      speaker: create_user
    }
    Session.create!(default_attributes.merge(attributes))
  end
end

class ActionDispatch::IntegrationTest
  # Helper method to login a user for integration tests
  def login_as(user)
    # Create a valid login token
    token = LoginToken.create!(
      user: user,
      token: SecureRandom.urlsafe_base64(32),
      expires_at: 1.hour.from_now
    )

    # Use the magic login to set the session
    get magic_login_path(token.token)
    follow_redirect!
  end

  # Helper method to assert flash message
  def assert_flash(type, message)
    assert_equal message, flash[type]
  end

  # Helper method to assert redirect with flash
  def assert_redirect_with_flash(path, flash_type, message)
    assert_redirected_to path
    assert_flash(flash_type, message)
  end

  # Helper method to assert successful response with content
  def assert_success_with_content(content)
    assert_response :success
    assert_select content
  end

  # Helper method to assert authentication required
  def assert_authentication_required
    assert_redirected_to login_path
  end

  # Helper method to assert admin access required
  def assert_admin_access_required
    assert_redirected_to agenda_path
    assert_flash(:alert, "Access denied. Admin privileges required.")
  end
end
