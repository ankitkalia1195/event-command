class MagicLoginController < ApplicationController
  skip_before_action :authenticate_user!
  layout "login"

  def show
    token = params[:token]

    if token.blank?
      redirect_to root_path, alert: "Invalid login link."
      return
    end

    login_token = LoginToken.find_valid(token)

    if login_token.nil?
      redirect_to root_path, alert: "Invalid or expired login link."
      return
    end

    # Log user in
    session[:user_id] = login_token.user.id
    login_token.use!

    flash[:notice] = "Successfully logged in!"
    redirect_to agenda_path
  end
end
