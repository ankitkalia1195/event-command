class SessionsController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :new, :create, :magic_login, :face_login, :face_authenticate ]
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

  # Face login page
  def face_login
    # Render the face login view with webcam
  end

  # Face authentication endpoint
  def face_authenticate
    image_data = params[:face_image]

    if image_data.blank?
      render json: { success: false, error: "Missing face image" }, status: :bad_request
      return
    end

    # Get all users with face encodings
    users_with_faces = User.where.not(face_encoding_data: [ nil, "" ])

    if users_with_faces.empty?
      render json: { success: false, error: "No registered faces found" }, status: :unprocessable_entity
      return
    end

    # Prepare known encodings for the Python service
    known_encodings = users_with_faces.map do |user|
      begin
        encoding = JSON.parse(user.face_encoding_data)
        { user_id: user.id, encoding: encoding }
      rescue JSON::ParserError
        Rails.logger.warn "Invalid face encoding for user #{user.id}"
        nil
      end
    end.compact

    if known_encodings.empty?
      render json: { success: false, error: "No valid face encodings found" }, status: :unprocessable_entity
      return
    end

    # Call Python service for authentication
    result = FaceRecognitionService.authenticate_face(image_data, known_encodings)

    if result[:success] && result[:authenticated]
      # Log the user in
      user = User.find(result[:user_id])
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
        error: result[:error] || "Face authentication failed"
      }, status: :unauthorized
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
