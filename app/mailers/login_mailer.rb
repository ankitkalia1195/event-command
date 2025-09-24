class LoginMailer < ApplicationMailer
  def magic_link(user, login_token)
    @user = user
    @login_token = login_token
    @magic_link = magic_login_url(token: @login_token.token)

    mail(
      to: @user.email,
      subject: "Your Command O Conference Login Link"
    )
  end

  private

  def magic_login_url(token:)
    Rails.application.routes.url_helpers.magic_login_url(
      token: token,
      host: Rails.application.config.action_mailer.default_url_options[:host],
      port: Rails.application.config.action_mailer.default_url_options[:port]
    )
  end
end
