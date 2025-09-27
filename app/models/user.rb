class User < ApplicationRecord
  # Validations
  validates :name, presence: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :role, inclusion: { in: %w[attendee admin] }

  # Custom validation for company email domain
  validate :company_email_domain

  # Associations
  has_many :sessions, foreign_key: :speaker_id, dependent: :nullify
  has_many :feedbacks, dependent: :destroy
  has_many :login_tokens, dependent: :destroy

  # Scopes
  scope :attendees, -> { where(role: "attendee") }
  scope :admins, -> { where(role: "admin") }
  scope :speakers, -> { where(is_speaker: true) }
  scope :checked_in, -> { where(checked_in: true) }

  # Face recognition methods
  def has_face_encoding?
    face_encoding_data.present?
  end

  def face_encoding
    return nil unless has_face_encoding?
    JSON.parse(face_encoding_data)
  rescue JSON::ParserError
    nil
  end

  def face_encoding=(encoding_array)
    self.face_encoding_data = encoding_array.to_json
  end

  # Methods
  def admin?
    role == "admin"
  end

  def attendee?
    role == "attendee"
  end

  def speaker?
    is_speaker?
  end

  def can_access_admin?
    admin?
  end

  private

  def company_email_domain
    return if email.blank?

    # Only allow @company.com domain for now
    # In production, this should be configurable
    unless email.end_with?("@company.com")
      errors.add(:email, "must be a company email address")
    end
  end
end
