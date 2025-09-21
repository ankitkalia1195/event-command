class SessionsController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :new, :create, :magic_login ]
  layout "login", only: [ :new ]

  def new
    redirect_to agenda_path if user_signed_in?
  end

  def create
    email = params[:email]&.strip&.downcase

    if email.blank?
      flash.now[:alert] = "Please enter your email address."
      render :new, status: :unprocessable_entity
      return
    end

    # Validate company email domain
    unless email.end_with?("@company.com")
      flash.now[:alert] = "Please use your company email address."
      render :new, status: :unprocessable_entity
      return
    end

    # Find or create user
    user = User.find_or_create_by(email: email) do |u|
      u.name = email.split("@").first.humanize
      u.role = "attendee"
    end

    # Generate login token
    login_token = LoginToken.generate_for_user(user)

    # Send magic link email
    LoginMailer.magic_link(user, login_token).deliver_now

    flash[:notice] = "Check your email for a login link!"
    redirect_to root_path
  rescue => e
    Rails.logger.error "Login error: #{e.message}"
    flash.now[:alert] = "An error occurred. Please try again."
    render :new, status: :unprocessable_entity
  end

  def magic_login
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
  rescue => e
    Rails.logger.error "Magic login error: #{e.message}"
    redirect_to root_path, alert: "An error occurred during login."
  end

  def destroy
    session[:user_id] = nil
    session[:admin_view] = nil
    redirect_to root_path, notice: "Successfully logged out!"
  end
end
