class User < ApplicationRecord
  attr_accessor :remember_token, :activation_token
  before_save :down_email
  before_create :create_activation_digest

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
  class << self
    def digest(string)
      cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
      BCrypt::Password.create(string, cost: cost)
    end

    # ランダムなトークン(文字列)をBase64形式で返す
    def new_token
      SecureRandom.urlsafe_base64
    end
  end

  # 記憶トークンをDBに登録する
  def remember
    self.remember_token = User.new_token
    update_attributes({ remember_digest: User.digest(self.remember_token) })
  end

  # 記憶トークンをDBから削除する
  def forget
    update_attributes({ remember_digest: nil })
  end

  # CookieとDBの記憶トークンが一致するかどうかを返す
  def authenticated?(remember_token)
    return false if remember_digest.nil?
    BCrypt::Password.new(remember_digest).is_password?(remember_token)
  end

  # ======================================
  private

  def down_email
    email.downcase!
  end

  def create_activation_digest
    self.activation_token = User.new_token
    self.activation_digest = User.digest(self.activation_token)
  end
end
