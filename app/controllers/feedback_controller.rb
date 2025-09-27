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
      respond_to do |format|
        format.html { redirect_to session_path(@session), notice: "Thank you for your feedback!" }
        format.turbo_stream { redirect_to session_path(@session), notice: "Thank you for your feedback!" }
      end
    else
      Rails.logger.debug "Session feedback errors: #{@feedback.errors.full_messages}"
      respond_to do |format|
        format.html { render :new_session, status: :unprocessable_entity }
        format.turbo_stream { render :new_session, status: :unprocessable_entity }
      end
    end
  end

  def edit_session
    @session = Session.find(params[:session_id])
    @feedback = current_user.feedbacks.find(params[:id])

    unless @session.can_receive_feedback?
      redirect_to session_path(@session), alert: "Feedback is only available after the session ends."
      nil
    end
  end

  def update_session
    @session = Session.find(params[:session_id])
    @feedback = current_user.feedbacks.find(params[:id])

    # Debug logging
    Rails.logger.debug "Session feedback update params: #{feedback_params.inspect}"
    Rails.logger.debug "Rating value: #{@feedback.rating.inspect}"

    if @feedback.update(feedback_params)
      respond_to do |format|
        format.html { redirect_to session_path(@session), notice: "Your feedback has been updated!" }
        format.turbo_stream { redirect_to session_path(@session), notice: "Your feedback has been updated!" }
      end
    else
      Rails.logger.debug "Session feedback update errors: #{@feedback.errors.full_messages}"
      respond_to do |format|
        format.html { render :edit_session, status: :unprocessable_entity }
        format.turbo_stream { render :edit_session, status: :unprocessable_entity }
      end
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
      respond_to do |format|
        format.html { redirect_to agenda_path, notice: "Thank you for your overall event feedback!" }
        format.turbo_stream { redirect_to agenda_path, notice: "Thank you for your overall event feedback!" }
      end
    else
      Rails.logger.debug "Feedback errors: #{@feedback.errors.full_messages}"
      respond_to do |format|
        format.html { render :new_event, status: :unprocessable_entity }
        format.turbo_stream { render :new_event, status: :unprocessable_entity }
      end
    end
  end

  def edit_event
    @feedback = current_user.feedbacks.find(params[:id])
  end

  def update_event
    @feedback = current_user.feedbacks.find(params[:id])

    # Debug logging
    Rails.logger.debug "Event feedback update params: #{feedback_params.inspect}"
    Rails.logger.debug "Rating value: #{@feedback.rating.inspect}"

    if @feedback.update(feedback_params)
      respond_to do |format|
        format.html { redirect_to agenda_path, notice: "Your overall event feedback has been updated!" }
        format.turbo_stream { redirect_to agenda_path, notice: "Your overall event feedback has been updated!" }
      end
    else
      Rails.logger.debug "Event feedback update errors: #{@feedback.errors.full_messages}"
      respond_to do |format|
        format.html { render :edit_event, status: :unprocessable_entity }
        format.turbo_stream { render :edit_event, status: :unprocessable_entity }
      end
    end
  end

  private

  def feedback_params
    params.require(:feedback).permit(:rating, :comment)
  end
end
