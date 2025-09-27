require "test_helper"

class FeedbackControllerTest < ActionDispatch::IntegrationTest
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

    # Create a past session for feedback
    @session = Session.create!(
      title: "Test Session",
      abstract: "Test Description",
      start_time: 2.hours.ago,
      end_time: 1.hour.ago,
      speaker: @speaker
    )

    # Create an upcoming session (should not allow feedback)
    @upcoming_session = Session.create!(
      title: "Upcoming Session",
      abstract: "Upcoming Description",
      start_time: 1.hour.from_now,
      end_time: 2.hours.from_now,
      speaker: @speaker
    )
  end

  def login_user
    login_as(@user)
  end

  # Session Feedback Tests
  test "should get new session feedback form" do
    login_user

    get new_session_feedback_path(@session)

    assert_response :success
    assert_select "h1", "Session Feedback"
    assert_select "form[action=?]", create_session_feedback_path(@session)
  end

  test "should create session feedback successfully" do
    login_user

    assert_difference "Feedback.count", 1 do
      post create_session_feedback_path(@session), params: {
        feedback: {
          rating: 5,
          comment: "Great session!"
        }
      }
    end

    assert_redirected_to session_path(@session)
    assert_equal "Thank you for your feedback!", flash[:notice]

    feedback = Feedback.last
    assert_equal @user, feedback.user
    assert_equal @session, feedback.session
    assert_equal 5, feedback.rating
    assert_equal "Great session!", feedback.comment
  end

  test "should not create session feedback for upcoming session" do
    login_user

    get new_session_feedback_path(@upcoming_session)

    assert_redirected_to session_path(@upcoming_session)
    assert_equal "Feedback is only available after the session ends.", flash[:alert]
  end

  test "should not create duplicate session feedback" do
    login_user

    # Create first feedback
    @user.feedbacks.create!(
      session: @session,
      rating: 4,
      comment: "First feedback"
    )

    assert_no_difference "Feedback.count" do
      post create_session_feedback_path(@session), params: {
        feedback: {
          rating: 5,
          comment: "Second feedback"
        }
      }
    end

    assert_redirected_to new_session_feedback_path(@session)
  end

  test "should handle session feedback validation errors" do
    login_user

    assert_no_difference "Feedback.count" do
      post create_session_feedback_path(@session), params: {
        feedback: {
          rating: "",
          comment: "No rating"
        }
      }
    end

    assert_redirected_to new_session_feedback_path(@session)
    assert_match /Please fix the errors/, flash[:alert]
  end

  test "should get edit session feedback form" do
    login_user

    # Create existing feedback
    feedback = @user.feedbacks.create!(
      session: @session,
      rating: 4,
      comment: "Original feedback"
    )

    get edit_session_feedback_path(@session, feedback)

    assert_response :success
    assert_select "h1", "Edit Session Feedback"
    assert_select "form[action=?]", update_session_feedback_path(@session, feedback)
    assert_select "input[value=?]", "4"
  end

  test "should update session feedback successfully" do
    login_user

    # Create existing feedback
    feedback = @user.feedbacks.create!(
      session: @session,
      rating: 3,
      comment: "Original comment"
    )

    patch update_session_feedback_path(@session, feedback), params: {
      feedback: {
        rating: 5,
        comment: "Updated comment"
      }
    }

    assert_redirected_to session_path(@session)
    assert_equal "Your feedback has been updated!", flash[:notice]

    feedback.reload
    assert_equal 5, feedback.rating
    assert_equal "Updated comment", feedback.comment
  end

  test "should handle session feedback update validation errors" do
    login_user

    feedback = @user.feedbacks.create!(
      session: @session,
      rating: 4,
      comment: "Original comment"
    )

    patch update_session_feedback_path(@session, feedback), params: {
      feedback: {
        rating: "",
        comment: "No rating"
      }
    }

    assert_redirected_to edit_session_feedback_path(@session, feedback)
    assert_match /Please fix the errors/, flash[:alert]
  end

  # Overall Event Feedback Tests
  test "should get new event feedback form" do
    login_user

    get new_event_feedback_path

    assert_response :success
    assert_select "h1", "Overall Event Feedback"
    assert_select "form[action=?]", create_event_feedback_path
  end

  test "should create overall event feedback successfully" do
    login_user

    assert_difference "Feedback.count", 1 do
      post create_event_feedback_path, params: {
        feedback: {
          rating: 5,
          comment: "Excellent conference!"
        }
      }
    end

    assert_redirected_to agenda_path
    assert_equal "Thank you for your overall event feedback!", flash[:notice]

    feedback = Feedback.last
    assert_equal @user, feedback.user
    assert_nil feedback.session
    assert_equal 5, feedback.rating
    assert_equal "Excellent conference!", feedback.comment
  end

  test "should not create duplicate overall event feedback" do
    login_user

    # Create first overall feedback
    @user.feedbacks.create!(
      session: nil,
      rating: 4,
      comment: "First overall feedback"
    )

    assert_no_difference "Feedback.count" do
      post create_event_feedback_path, params: {
        feedback: {
          rating: 5,
          comment: "Second overall feedback"
        }
      }
    end

    assert_redirected_to agenda_path
    assert_equal "You have already provided overall event feedback.", flash[:alert]
  end

  test "should handle overall event feedback validation errors" do
    login_user

    assert_no_difference "Feedback.count" do
      post create_event_feedback_path, params: {
        feedback: {
          rating: "",
          comment: "No rating"
        }
      }
    end

    assert_redirected_to new_event_feedback_path
    assert_match /Please fix the errors/, flash[:alert]
  end

  test "should get edit event feedback form" do
    login_user

    # Create existing overall feedback
    feedback = @user.feedbacks.create!(
      session: nil,
      rating: 4,
      comment: "Original overall feedback"
    )

    get edit_event_feedback_path(feedback)

    assert_response :success
    assert_select "h1", "Edit Overall Event Feedback"
    assert_select "form[action=?]", update_event_feedback_path(feedback)
    assert_select "input[value=?]", "4"
  end

  test "should update overall event feedback successfully" do
    login_user

    # Create existing overall feedback
    feedback = @user.feedbacks.create!(
      session: nil,
      rating: 3,
      comment: "Original overall comment"
    )

    patch update_event_feedback_path(feedback), params: {
      feedback: {
        rating: 5,
        comment: "Updated overall comment"
      }
    }

    assert_redirected_to agenda_path
    assert_equal "Your overall event feedback has been updated!", flash[:notice]

    feedback.reload
    assert_equal 5, feedback.rating
    assert_equal "Updated overall comment", feedback.comment
  end

  test "should handle overall event feedback update validation errors" do
    login_user

    feedback = @user.feedbacks.create!(
      session: nil,
      rating: 4,
      comment: "Original overall comment"
    )

    patch update_event_feedback_path(feedback), params: {
      feedback: {
        rating: "",
        comment: "No rating"
      }
    }

    assert_redirected_to edit_event_feedback_path(feedback)
    assert_match /Please fix the errors/, flash[:alert]
  end

  test "should require authentication for all feedback actions" do
    # Test new session feedback
    get new_session_feedback_path(@session)
    assert_redirected_to root_path

    # Test create session feedback
    post create_session_feedback_path(@session), params: { feedback: { rating: 5, comment: "Test" } }
    assert_redirected_to root_path

    # Test new event feedback
    get new_event_feedback_path
    assert_redirected_to root_path

    # Test create event feedback
    post create_event_feedback_path, params: { feedback: { rating: 5, comment: "Test" } }
    assert_redirected_to root_path
  end

  test "should only allow users to edit their own feedback" do
    # Create another user
    other_user = User.create!(
      name: "Other User",
      email: "other@example.com",
      role: "attendee"
    )

    # Create feedback for other user
    feedback = other_user.feedbacks.create!(
      session: @session,
      rating: 4,
      comment: "Other user feedback"
    )

    login_user

    # Try to edit other user's feedback
    get edit_session_feedback_path(@session, feedback)
    assert_response :not_found
  end
end
