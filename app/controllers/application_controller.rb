class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Authentication
  before_action :authenticate_user!
  before_action :set_current_user

  # Authorization
  before_action :ensure_admin_access, if: :admin_required?

  private

  def authenticate_user!
    unless current_user
      redirect_to root_path, alert: "Please log in to access this page."
    end
  end

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  rescue ActiveRecord::RecordNotFound
    session[:user_id] = nil
    nil
  end

  def set_current_user
    @current_user = current_user
  end

  def user_signed_in?
    current_user.present?
  end

  def admin_required?
    false # Override in controllers that require admin access
  end

  def ensure_admin_access
    unless current_user&.admin?
      redirect_to root_path, alert: "Access denied. Admin privileges required."
    end
  end

  def require_admin
    ensure_admin_access
  end

  def admin_view?
    session[:admin_view] == true
  end

  def switch_to_admin_view
    session[:admin_view] = true
    redirect_to admin_dashboard_path
  end

  def switch_to_attendee_view
    session[:admin_view] = false
    redirect_to agenda_path
  end
end
