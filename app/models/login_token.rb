class LoginToken < ApplicationRecord
  # Validations
  validates :token, presence: true, uniqueness: true
  validates :expires_at, presence: true
  validate :not_expired
  validate :not_used

  # Associations
  belongs_to :user

  # Scopes
  scope :valid, -> { where(used: false).where("expires_at > ?", Time.current) }
  scope :expired, -> { where("expires_at <= ?", Time.current) }
  scope :used, -> { where(used: true) }

  # Callbacks
  before_validation :generate_token, on: :create
  before_validation :set_expiration, on: :create

  # Methods
  def expired?
    expires_at <= Time.current
  end

  def token_valid?
    !used? && !expired?
  end

  def use!
    update!(used: true)
  end

  def self.generate_for_user(user)
    # Clean up old tokens for this user
    where(user_id: user.id).delete_all

    create!(user: user)
  end

  def self.find_valid(token)
    token_record = find_by(token: token, used: false)
    return nil unless token_record&.token_valid?
    token_record
  end

  private

  def generate_token
    self.token = SecureRandom.urlsafe_base64(32)
  end

  def set_expiration
    self.expires_at = 15.minutes.from_now
  end

  def not_expired
    return if expires_at.blank?

    if expired?
      errors.add(:expires_at, "has expired")
    end
  end

  def not_used
    if used?
      errors.add(:used, "token has already been used")
    end
  end
end
