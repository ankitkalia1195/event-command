class SessionsController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :new, :create, :magic_login, :face_authenticate, :face_login ]
  layout "login", only: [ :new, :face_login ]

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

    # Find or create user (any email domain is now allowed)
    user = User.find_or_create_by(email: email) do |u|
      u.name = email.split("@").first.humanize  # Set first name equal to email as requested
      u.role = "attendee"
    end

    # Generate login token
    login_token = LoginToken.generate_for_user(user)

    # Send magic link email via background job (runs in same process with Solid Queue)
    LoginEmailJob.perform_later(user.id, login_token.id)

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

  # Face login page
  def face_login
    # Render the face login view with webcam
  end

  # Face authentication endpoint
  def face_authenticate
    image_data = params[:face_image]
    Rails.logger.info "Received face authentication request"

    if image_data.blank?
      render json: { success: false, error: "Missing face image" }, status: :bad_request
      return
    end

    # Use the new User.authenticate_by_face method
    result = User.authenticate_by_face(image_data)

    if result[:success] && result[:authenticated]
      # Log the user in
      user = result[:user]
      session[:user_id] = user.id

      render json: {
        success: true,
        authenticated: true,
        user_id: user.id,
        user_name: user.name,
        confidence: result[:confidence]
      }
    else
      render json: {
        success: false,
        authenticated: false,
        error: result[:error] || "Face not recognized"
      }
    end

  rescue => e
    Rails.logger.error "Face authentication error: #{e.message}"
    render json: { success: false, error: "Internal server error" }, status: :internal_server_error
  end
  # Session details (for individual sessions)
  def show
    @session = Session.find(params[:id])
    @speaker = @session.speaker
    @current_user = current_user
  end
end
