class User < ApplicationRecord
  attr_accessor :remember_token
  before_save { email.downcase! }

  validates(
    :name,
    {
      presence: true,
      length: { maximum: 50 },
    },
  )

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates(
    :email,
    {
      presence: true,
      length: { maximum: 255 },
      format: { with: VALID_EMAIL_REGEX },
      uniqueness: { case_sensitive: false },
    },
  )

  has_secure_password
  validates(
    :password,
    {
      presence: true,
      allow_nil: true,
      length: { minimum: 6 },
    },
  )

  # 引数の文字列のハッシュを返す
  def self.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  # ランダムなトークン(文字列)をBase64形式で返す
  def self.new_token
    SecureRandom.urlsafe_base64
  end

  def remember
    self.remember_token = User.new_token
    update_attributes({ remember_digest: User.digest(self.remember_token) })
  end
end
