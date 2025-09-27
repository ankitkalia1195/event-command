require "test_helper"

class AgendaControllerTest < ActionDispatch::IntegrationTest
  def setup
    # Create test data
    @user = User.create!(
      name: "Test User",
      email: "test@example.com",
      role: "attendee"
    )

    @speaker = User.create!(
      name: "Speaker User",
      email: "speaker@example.com",
      role: "attendee"
    )

    # Create sessions at different times
    @past_session = Session.create!(
      title: "Past Session",
      abstract: "Past Description",
      start_time: 2.hours.ago,
      end_time: 1.hour.ago,
      speaker: @speaker
    )

    @current_session = Session.create!(
      title: "Current Session",
      abstract: "Current Description",
      start_time: 30.minutes.ago,
      end_time: 30.minutes.from_now,
      speaker: @speaker
    )

    @upcoming_session = Session.create!(
      title: "Upcoming Session",
      abstract: "Upcoming Description",
      start_time: 1.hour.from_now,
      end_time: 2.hours.from_now,
      speaker: @speaker
    )
  end

  test "should get agenda page for logged in user" do
    login_as(@user)

    get agenda_path

    assert_response :success
    assert_select "h1", "Conference Agenda"
    assert_select ".bg-gray-900.rounded-lg", count: 4  # 3 sessions + 1 check-in section
  end

  test "should require authentication for agenda page" do
    get agenda_path
    assert_redirected_to root_path
  end

  test "should show check-in button for logged out user" do
    login_as(@user)

    get agenda_path

    assert_select "input[type=submit][value='Check In']"
    assert_select "form[action=?]", check_in_path
  end

  test "should show checked-in status for checked-in user" do
    @user.update!(checked_in: true)
    login_as(@user)

    get agenda_path

    assert_select ".bg-green-600", text: "Checked In"
    assert_select "button[data-turbo-method=?]", "post", count: 0
  end

  test "should allow user to check in" do
    login_as(@user)

    assert_changes -> { @user.reload.checked_in? }, from: false, to: true do
      post check_in_path, params: {}, headers: { "Accept" => "text/vnd.turbo-stream.html" }
    end

    assert_response :success
    # Flash message is handled via Turbo Stream partial, not Rails flash
  end

  test "should not allow already checked-in user to check in again" do
    @user.update!(checked_in: true)
    login_as(@user)

    assert_no_changes -> { @user.reload.checked_in? } do
      post check_in_path, params: {}, headers: { "Accept" => "text/vnd.turbo-stream.html" }
    end

    assert_response :unprocessable_entity
    # Flash message is handled via Turbo Stream partial, not Rails flash
  end

  test "should show feedback button for past sessions" do
    login_as(@user)

    get agenda_path

    # Should show feedback button for past session
    assert_select "a[href=?]", new_session_feedback_path(@past_session)

    # Should not show feedback button for upcoming session
    assert_select "a[href=?]", new_session_feedback_path(@upcoming_session), count: 0
  end

  test "should show edit feedback button for sessions with existing feedback" do
    login_as(@user)

    # Create feedback for past session
    feedback = @user.feedbacks.create!(
      session: @past_session,
      rating: 4,
      comment: "Great session!"
    )

    get agenda_path

    # Should show edit feedback button
    assert_select "a[href=?]", edit_session_feedback_path(@past_session, feedback)
    assert_select "a[href=?]", new_session_feedback_path(@past_session), count: 0
  end

  test "should show overall event feedback button" do
    login_as(@user)

    get agenda_path

    assert_select "a[href=?]", new_event_feedback_path
  end

  test "should show edit overall event feedback button when feedback exists" do
    login_as(@user)

    # Create overall event feedback
    feedback = @user.feedbacks.create!(
      session: nil,
      rating: 5,
      comment: "Excellent conference!"
    )

    get agenda_path

    # Should show edit button
    assert_select "a[href=?]", edit_event_feedback_path(feedback)
    assert_select "a[href=?]", new_event_feedback_path, count: 0
  end

  test "should show session status for current session" do
    login_as(@user)

    get agenda_path

    # Should show sessions including current session
    assert_select ".bg-gray-900.rounded-lg", minimum: 1  # Session cards
    assert_select "a", text: @current_session.title
  end

  test "should show check-in statistics" do
    # Create some checked-in users
    User.create!([
      { name: "User 1", email: "user1@example.com", role: "attendee", checked_in: true },
      { name: "User 2", email: "user2@example.com", role: "attendee", checked_in: true },
      { name: "User 3", email: "user3@example.com", role: "attendee", checked_in: false }
    ])

    login_as(@user)

    get agenda_path

    # Should show check-in section
    assert_select "#check-in-button"
    assert_select "h2", "Event Check-In"
    # Check-in section should be present
  end

  test "should handle check-in with HTML format" do
    login_as(@user)

    post check_in_path, params: {}, headers: { "Accept" => "text/html" }

    assert_redirected_to agenda_path
    assert_equal "✅ You're checked in! Welcome to Command O Conference", flash[:notice]
  end

  test "should handle check-in with Turbo Stream format" do
    login_as(@user)

    post check_in_path, params: {}, headers: { "Accept" => "text/vnd.turbo-stream.html" }

    assert_response :success
    assert_equal "text/vnd.turbo-stream.html", response.media_type
  end

  test "should get session status partial" do
    login_as(@user)

    get agenda_session_status_path, params: {}, headers: { "Accept" => "text/html" }

    assert_response :success
    assert_select "#session-status"
  end

  test "should get check-in stats partial" do
    login_as(@user)

    get agenda_check_in_stats_path, params: {}, headers: { "Accept" => "text/html" }

    assert_response :success
    assert_select "#check-in-stats"
  end

  test "should handle session status with Turbo Stream format" do
    login_as(@user)

    get agenda_session_status_path, params: {}, headers: { "Accept" => "text/vnd.turbo-stream.html" }

    assert_response :success
    assert_equal "text/vnd.turbo-stream.html", response.media_type
  end

  test "should handle check-in stats with Turbo Stream format" do
    login_as(@user)

    get agenda_check_in_stats_path, params: {}, headers: { "Accept" => "text/vnd.turbo-stream.html" }

    assert_response :success
    assert_equal "text/vnd.turbo-stream.html", response.media_type
  end
end
