require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  def setup
    # Create test data
    @user = User.create!(
      name: "Test User",
      email: "test@example.com",
      role: "attendee"
    )

    @admin_user = User.create!(
      name: "Admin User",
      email: "admin@example.com",
      role: "admin"
    )
  end

  test "should get login page" do
    get login_path
    assert_response :success
    assert_select "h2", "Command O Conference"
  end

  test "should redirect to agenda if already logged in" do
    login_as(@user)

    # Now try to access login page while logged in
    get login_path
    assert_redirected_to agenda_path
  end

  test "should create user and send magic link for new email" do
    assert_difference "User.count", 1 do
      assert_difference "LoginToken.count", 1 do
        assert_enqueued_jobs 1, only: LoginEmailJob do
          post login_path, params: { email: "newuser@example.com" }
        end
      end
    end

    assert_redirected_to root_path
    assert_equal "Check your email for a login link!", flash[:notice]

    # Verify user was created
    new_user = User.find_by(email: "newuser@example.com")
    assert_not_nil new_user
    assert_equal "attendee", new_user.role
    assert_equal "Newuser", new_user.name  # Name is set to humanized first part of email
  end

  test "should not create duplicate user for existing email" do
    assert_no_difference "User.count" do
      assert_difference "LoginToken.count", 1 do
        assert_enqueued_jobs 1, only: LoginEmailJob do
          post login_path, params: { email: @user.email }
        end
      end
    end

    assert_redirected_to root_path
  end

  test "should reject blank email" do
    assert_no_difference "User.count" do
      assert_no_difference "LoginToken.count" do
        assert_no_emails do
          post login_path, params: { email: "" }
        end
      end
    end

    assert_response :unprocessable_entity
    assert_equal "Please enter your email address.", flash[:alert]
  end

  test "should reject invalid email format" do
    assert_no_difference "User.count" do
      assert_no_difference "LoginToken.count" do
        assert_no_emails do
          post login_path, params: { email: "invalid-email" }
        end
      end
    end

    assert_response :unprocessable_entity
  end

  test "should login with valid magic link" do
    login_token = LoginToken.generate_for_user(@user)

    get magic_login_path(login_token.token)

    assert_redirected_to agenda_path
    assert_equal "Successfully logged in!", flash[:notice]
    assert_equal @user.id, session[:user_id]
    assert login_token.reload.used?
  end

  test "should reject invalid magic link" do
    get magic_login_path("invalid-token")

    assert_redirected_to root_path
    assert_equal "Invalid or expired login link.", flash[:alert]
  end

  test "should reject expired magic link" do
    login_token = LoginToken.generate_for_user(@user)
    login_token.update_column(:expires_at, 1.hour.ago)  # Bypass validation

    get magic_login_path(login_token.token)

    assert_redirected_to root_path
    assert_equal "Invalid or expired login link.", flash[:alert]
  end

  test "should reject used magic link" do
    login_token = LoginToken.generate_for_user(@user)
    login_token.use!

    get magic_login_path(login_token.token)

    assert_redirected_to root_path
    assert_equal "Invalid or expired login link.", flash[:alert]
  end

  test "should logout successfully" do
    login_as(@user)

    delete logout_path

    assert_redirected_to root_path
    assert_equal "Successfully logged out!", flash[:notice]
    assert_nil session[:user_id]
  end

  test "should show session details for logged in user" do
    # Create a session
    session_obj = Session.create!(
      title: "Test Session",
      abstract: "Test Description",
      start_time: 1.hour.from_now,
      end_time: 2.hours.from_now,
      speaker: @user
    )

    # Login using helper
    login_as(@user)

    get session_path(session_obj)

    assert_response :success
    assert_select "h1", session_obj.title
  end

  test "should require authentication for session details" do
    session_obj = Session.create!(
      title: "Test Session",
      abstract: "Test Description",
      start_time: 1.hour.from_now,
      end_time: 2.hours.from_now,
      speaker: @user
    )

    get session_path(session_obj)

    assert_redirected_to root_path
  end
end
