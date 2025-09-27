class AgendaController < ApplicationController
  def index
    @sessions = Session.chronological.includes(:speaker)
    @current_user = current_user
  end

  def check_in
    if current_user.checked_in?
      respond_to do |format|
        format.html { redirect_to agenda_path, alert: "You are already checked in." }
        format.turbo_stream {
          render turbo_stream: [
            turbo_stream.replace(
              "check-in-button",
              partial: "agenda/check_in_button",
              locals: { user: current_user }
            ),
            turbo_stream.replace(
              "flash-messages",
              partial: "shared/flash_messages",
              locals: { flash: { alert: "You are already checked in." } }
            )
          ], status: :unprocessable_entity
        }
      end
    elsif current_user.update(checked_in: true)
      respond_to do |format|
        format.html { redirect_to agenda_path, notice: "✅ You're checked in! Welcome to Command O Conference" }
        format.turbo_stream {
          render turbo_stream: [
            turbo_stream.replace(
              "check-in-button",
              partial: "agenda/check_in_button",
              locals: { user: current_user }
            ),
            turbo_stream.replace(
              "flash-messages",
              partial: "shared/flash_messages",
              locals: { flash: { notice: "✅ You're checked in! Welcome to Command O Conference" } }
            )
          ]
        }
      end
    else
      respond_to do |format|
        format.html { redirect_to agenda_path, alert: "Check-in failed. Please try again." }
        format.turbo_stream {
          render turbo_stream: [
            turbo_stream.replace(
              "check-in-button",
              partial: "agenda/check_in_button",
              locals: { user: current_user }
            ),
            turbo_stream.replace(
              "flash-messages",
              partial: "shared/flash_messages",
              locals: { flash: { alert: "Check-in failed. Please try again." } }
            )
          ]
        }
      end
    end
  end

  def session_status
    @current_session = Session.current.first

    respond_to do |format|
      format.html { render partial: "session_status" }
      format.turbo_stream { render partial: "session_status", formats: [ :html ] }
    end
  end

  def check_in_stats
    @total_attendees = User.where(role: [ "attendee", "admin" ]).count
    @checked_in_count = User.where(role: [ "attendee", "admin" ]).checked_in.count

    respond_to do |format|
      format.html { render partial: "check_in_stats" }
      format.turbo_stream { render partial: "check_in_stats", formats: [ :html ] }
    end
  end
end
