# Example background job that can run in same process
class LoginEmailJob < ApplicationJob
  queue_as :default

  # This job will run in the same process as your web server
  # when using Solid Queue (Rails 8 default)
  def perform(user_id, login_token_id)
    user = User.find(user_id)
    login_token = LoginToken.find(login_token_id)

    # Send magic login email
    LoginMailer.magic_link(user, login_token).deliver_now

    Rails.logger.info "Magic login email sent to #{user.email}"
  rescue StandardError => e
    Rails.logger.error "Failed to send login email: #{e.message}"
    raise # Re-raise to trigger retry logic
  end
end
