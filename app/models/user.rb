class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }

  def self.authenticate_with_password(email_address:, password:)
    user = find_by(email_address: email_address.to_s.strip.downcase)
    return unless user

    user.authenticate(password)
  rescue BCrypt::Errors::InvalidHash
    nil
  end
end
