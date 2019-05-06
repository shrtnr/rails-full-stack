class User < ApplicationRecord
  has_secure_password

  has_many :shortcodes

  validates :email, presence: true
  validates :password, confirmation: true
  validates :password_confirmation, presence: true, if: :password_digest_changed?

  def as_json(*_)
    { id: id, email: email, admin: admin, created_at: created_at, updated_at: updated_at }
  end

  def to_jwt
    payload = { "sub": email }
    secret = Rails.application.credentials.jwt_hash_secret
    JWT.encode(payload, secret, 'HS256')
  end

  def self.from_jwt(jwt)
    secret = Rails.application.credentials.jwt_hash_secret
    payload = JWT.decode(jwt, secret, 'HS256').first
    find_by(email: payload["sub"])
  rescue JWT::DecodeError
    return nil
  end
end
