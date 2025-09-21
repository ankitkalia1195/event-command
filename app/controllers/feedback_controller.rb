class FeedbackController < ApplicationController
  def new_session
    @session = Session.find(params[:id])
    @feedback = @session.feedbacks.build(user: current_user)

    unless @session.can_receive_feedback?
      redirect_to session_path(@session), alert: "Feedback is only available after the session ends."
      nil
    end
  end

  def create_session
    @session = Session.find(params[:id])
    @feedback = @session.feedbacks.build(feedback_params.merge(user: current_user))

    # Debug logging
    Rails.logger.debug "Session feedback params: #{feedback_params.inspect}"
    Rails.logger.debug "Rating value: #{@feedback.rating.inspect}"

    if @feedback.save
      redirect_to session_path(@session), notice: "Thank you for your feedback!"
    else
      Rails.logger.debug "Session feedback errors: #{@feedback.errors.full_messages}"
      render :new_session, status: :unprocessable_entity
    end
  end

  def new_event
    @feedback = current_user.feedbacks.build(session: nil)

    if current_user.feedbacks.overall_feedback.exists?
      redirect_to agenda_path, alert: "You have already provided overall event feedback."
      nil
    end
  end

  def create_event
    @feedback = current_user.feedbacks.build(feedback_params.merge(session: nil))

    # Debug logging
    Rails.logger.debug "Feedback params: #{feedback_params.inspect}"
    Rails.logger.debug "Rating value: #{@feedback.rating.inspect}"

    if @feedback.save
      redirect_to agenda_path, notice: "Thank you for your overall event feedback!"
    else
      Rails.logger.debug "Feedback errors: #{@feedback.errors.full_messages}"
      render :new_event, status: :unprocessable_entity
    end
  end

  private

  def feedback_params
    params.require(:feedback).permit(:rating, :comment)
  end
end
