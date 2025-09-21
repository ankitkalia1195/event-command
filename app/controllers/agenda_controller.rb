class AgendaController < ApplicationController
  def index
    @sessions = Session.chronological.includes(:speaker)
    @current_user = current_user
  end

  def check_in
    if current_user.update(checked_in: true)
      respond_to do |format|
        format.html { redirect_to agenda_path, notice: "Successfully checked in!" }
        format.turbo_stream {
          render turbo_stream: turbo_stream.replace(
            "check-in-button",
            partial: "agenda/check_in_button",
            locals: { user: current_user }
          )
        }
      end
    else
      respond_to do |format|
        format.html { redirect_to agenda_path, alert: "Check-in failed. Please try again." }
        format.turbo_stream {
          render turbo_stream: turbo_stream.replace(
            "check-in-button",
            partial: "agenda/check_in_button",
            locals: { user: current_user }
          )
        }
      end
    end
  end
end
