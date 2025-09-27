class Admin::AdminController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_admin_access

  def dashboard
    @total_attendees = User.attendees.count
    @checked_in_attendees = User.attendees.checked_in.count
    @total_sessions = Session.count
    @total_feedback = Feedback.count
    @overall_feedback = Feedback.overall_feedback.count
    @session_feedback = Feedback.session_feedback.count

    # Recent feedback
    @recent_feedback = Feedback.includes(:user, :session)
                              .order(created_at: :desc)
                              .page(params[:page])
                              .per(10)

    # Feedback analytics
    @average_rating = Feedback.average(:rating)&.round(1) || 0
    @rating_distribution = (1..5).map do |rating|
      count = Feedback.where(rating: rating).count
      percentage = @total_feedback > 0 ? (count.to_f / @total_feedback * 100).round(1) : 0
      { rating: rating, count: count, percentage: percentage }
    end
  end

  def attendees
    @attendees = User.attendees.includes(:feedbacks)
                    .order(:name)
                    .page(params[:page])
                    .per(20)

    respond_to do |format|
      format.html
      format.csv {
        # Get all attendees for CSV export (no pagination)
        all_attendees = User.attendees.includes(:feedbacks).order(:name)
        send_data generate_attendees_csv(all_attendees), filename: "attendees-#{Date.current}.csv"
      }
    end
  end

  def feedback_results
    @overall_feedback = Feedback.overall_feedback.includes(:user)
    @session_feedback = Feedback.session_feedback.includes(:user, :session)

    # Overall feedback analytics
    @overall_average = @overall_feedback.average(:rating)&.round(1) || 0
    @overall_rating_distribution = (1..5).map do |rating|
      count = @overall_feedback.where(rating: rating).count
      percentage = @overall_feedback.count > 0 ? (count.to_f / @overall_feedback.count * 100).round(1) : 0
      { rating: rating, count: count, percentage: percentage }
    end

    # Session feedback analytics
    @session_average = @session_feedback.average(:rating)&.round(1) || 0
    @session_rating_distribution = (1..5).map do |rating|
      count = @session_feedback.where(rating: rating).count
      percentage = @session_feedback.count > 0 ? (count.to_f / @session_feedback.count * 100).round(1) : 0
      { rating: rating, count: count, percentage: percentage }
    end

    # Top sessions by rating
    @top_sessions = Session.joins(:feedbacks)
                          .group("sessions.id, sessions.title, sessions.speaker_id")
                          .select("sessions.id, sessions.title, sessions.speaker_id, AVG(feedbacks.rating) as avg_rating, COUNT(feedbacks.id) as feedback_count")
                          .having("COUNT(feedbacks.id) > 0")
                          .order("avg_rating DESC")
                          .limit(5)
  end

  def switch_to_attendee_view
    session[:admin_view] = false
    redirect_to agenda_path, notice: "Switched to attendee view"
  end

  private

  def generate_attendees_csv(attendees = @attendees)
    require "csv"

    CSV.generate(headers: true) do |csv|
      csv << [ "Name", "Email", "Checked In", "Feedback Count", "Last Feedback" ]

      attendees.each do |attendee|
        csv << [
          attendee.name,
          attendee.email,
          attendee.checked_in? ? "Yes" : "No",
          attendee.feedbacks.count,
          attendee.feedbacks.order(:created_at).last&.created_at&.strftime("%Y-%m-%d %H:%M")
        ]
      end
    end
  end
end
