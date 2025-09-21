class Session < ApplicationRecord
  # Validations
  validates :title, presence: true
  validates :start_time, presence: true
  validates :end_time, presence: true
  validate :end_time_after_start_time
  validate :no_overlapping_sessions

  # Associations
  belongs_to :speaker, class_name: "User"
  has_many :feedbacks, dependent: :destroy

  # Scopes
  scope :upcoming, -> { where("start_time > ?", Time.current) }
  scope :past, -> { where("end_time < ?", Time.current) }
  scope :current, -> { where("start_time <= ? AND end_time >= ?", Time.current, Time.current) }
  scope :chronological, -> { order(:start_time) }

  # Methods
  def upcoming?
    start_time > Time.current
  end

  def past?
    end_time < Time.current
  end

  def current?
    start_time <= Time.current && end_time >= Time.current
  end

  def duration
    end_time - start_time
  end

  def duration_in_minutes
    (duration / 1.minute).round
  end

  def average_rating
    return 0 if feedbacks.empty?

    feedbacks.average(:rating).round(1)
  end

  def feedback_count
    feedbacks.count
  end

  def can_receive_feedback?
    past?
  end

  private

  def end_time_after_start_time
    return if start_time.blank? || end_time.blank?

    if end_time <= start_time
      errors.add(:end_time, "must be after start time")
    end
  end

  def no_overlapping_sessions
    return if start_time.blank? || end_time.blank?

    overlapping = Session.where.not(id: id)
                        .where("(start_time < ? AND end_time > ?) OR (start_time < ? AND end_time > ?) OR (start_time >= ? AND end_time <= ?)",
                               end_time, start_time, end_time, start_time, start_time, end_time)

    if overlapping.exists?
      errors.add(:base, "Session time overlaps with another session")
    end
  end
end
