require "test_helper"

class LoginEmailJobTest < ActiveJob::TestCase
  include ActionMailer::TestHelper
  def setup
    @user = User.create!(
      name: "Test User",
      email: "test@example.com",
      role: "attendee"
    )
    
    @login_token = LoginToken.create!(
      user: @user,
      token: SecureRandom.urlsafe_base64(32),
      expires_at: 1.hour.from_now
    )
  end

  test "should send magic login email" do
    assert_emails 1 do
      LoginEmailJob.perform_now(@user.id, @login_token.id)
    end
  end

  test "should enqueue job with correct arguments" do
    assert_enqueued_with(job: LoginEmailJob, args: [@user.id, @login_token.id]) do
      LoginEmailJob.perform_later(@user.id, @login_token.id)
    end
  end

  test "should handle missing user gracefully" do
    assert_raises(ActiveRecord::RecordNotFound) do
      LoginEmailJob.perform_now(999999, @login_token.id)
    end
  end

  test "should handle missing login token gracefully" do
    assert_raises(ActiveRecord::RecordNotFound) do
      LoginEmailJob.perform_now(@user.id, 999999)
    end
  end

  test "should log successful email sending" do
    assert_logs_match /Magic login email sent to #{@user.email}/ do
      LoginEmailJob.perform_now(@user.id, @login_token.id)
    end
  end

  private

  def assert_logs_match(pattern)
    logs = []
    original_logger = Rails.logger
    
    # Capture logs
    Rails.logger = Logger.new(StringIO.new).tap do |logger|
      logger.formatter = proc { |severity, datetime, progname, msg| logs << msg }
    end
    
    yield
    
    assert logs.any? { |log| log.match?(pattern) }, "Expected logs to match #{pattern}, but got: #{logs}"
  ensure
    Rails.logger = original_logger
  end
end
