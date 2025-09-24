class Feedback < ApplicationRecord
  # Validations
  validates :rating, presence: true, inclusion: { in: 1..5 }
  validates :user_id, uniqueness: { scope: :session_id, message: "has already provided feedback for this session" }
  validate :session_feedback_allowed
  validate :overall_feedback_uniqueness

  # Associations
  belongs_to :user
  belongs_to :session, optional: true # nil for overall event feedback

  # Scopes
  scope :session_feedback, -> { where.not(session_id: nil) }
  scope :overall_feedback, -> { where(session_id: nil) }
  scope :by_rating, ->(rating) { where(rating: rating) }
  scope :recent, -> { order(created_at: :desc) }

  # Methods
  def session_feedback?
    session_id.present?
  end

  def overall_feedback?
    session_id.nil?
  end

  def rating_stars
    "\u2605" * rating + "\u2606" * (5 - rating)
  end

  def self.average_rating_for_session(session)
    where(session: session).average(:rating)&.round(1) || 0
  end

  def self.average_overall_rating
    overall_feedback.average(:rating)&.round(1) || 0
  end

  def self.rating_distribution
    (1..5).map do |rating|
      {
        rating: rating,
        count: by_rating(rating).count,
        percentage: (by_rating(rating).count.to_f / count * 100).round(1)
      }
    end
  end

  private

  def session_feedback_allowed
    return unless session_id.present?

    unless session&.can_receive_feedback?
      errors.add(:base, "Feedback can only be provided after the session ends")
    end
  end

  def overall_feedback_uniqueness
    return unless session_id.nil?

    if user.feedbacks.overall_feedback.exists?
      errors.add(:base, "You have already provided overall event feedback")
    end
  end
end
