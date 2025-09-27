require "base64"

class User < ApplicationRecord
  # Validations
  validates :name, presence: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :role, inclusion: { in: %w[attendee admin] }

  # Email domain validation removed - any email is now allowed

  # Associations
  has_many :sessions, foreign_key: :speaker_id, dependent: :nullify
  has_many :feedbacks, dependent: :destroy
  has_many :login_tokens, dependent: :destroy

  # Active Storage for face photos
  has_one_attached :face_photo

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

  def has_face_photo?
    face_photo.attached?
  end

  def face_photo_url
    return self[:face_photo_url] if self[:face_photo_url].present?
    return Rails.application.routes.url_helpers.rails_blob_path(face_photo, only_path: true) if has_face_photo?
    nil
  rescue => e
    Rails.logger.warn "Error generating face photo URL: #{e.message}"
    nil
  end

  def generate_face_encoding_from_photo
    return false unless has_face_photo?

    begin
      # Convert Active Storage attachment to base64
      photo_data = face_photo.download
      base64_image = "data:image/jpeg;base64,#{Base64.strict_encode64(photo_data)}"

      # Call face recognition service
      result = FaceRecognitionService.encode_face(base64_image)

      if result[:success] && result[:encoding]
        self.face_encoding = result[:encoding]
        save!
        true
      else
        false
      end
    rescue => e
      Rails.logger.error("Error generating face encoding: #{e.message}")
      false
    end
  end

  def self.with_face_encodings
    where.not(face_encoding_data: [ nil, "" ])
  end

  def self.authenticate_by_face(image_base64)
    known_encodings = with_face_encodings.map do |user|
      {
        user_id: user.id,
        encoding: user.face_encoding
      }
    end.compact

    return { success: false, error: "No face encodings found" } if known_encodings.empty?

    result = FaceRecognitionService.authenticate_face(image_base64, known_encodings)

    if result[:success] && result[:authenticated]
      user = find(result[:user_id])
      {
        success: true,
        authenticated: true,
        user: user,
        confidence: result[:confidence],
        distance: result[:distance]
      }
    else
      result
    end
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
end
