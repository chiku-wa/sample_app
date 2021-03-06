class User < ApplicationRecord
  # === Setter,Getter
  attr_accessor :remember_token, :activation_token, :reset_token

  # === フィルタリング
  before_save :down_email
  before_create :create_activation_digest

  # === 従属関係
  # マイクロポスト
  has_many(
    :microposts,
    { dependent: :destroy },
  )

  # 自身がフォローしているユーザの一覧を取得するための従属関係
  has_many(
    :active_relationships,
    {
      class_name: "FollowerFollowed",
      foreign_key: "follower_id",
      dependent: :destroy,
    },
  )
  has_many(
    :following,
    {
      through: :active_relationships,
      source: :followed,
    }
  )

  # 自身をフォローしているユーザ(フォロワー)の一覧を取得するための従属関係
  has_many(
    :passive_relationships,
    {
      class_name: "FollowerFollowed",
      foreign_key: "followed_id",
      dependent: :destroy,
    }
  )
  has_many(
    :followers,
    {
      through: :passive_relationships,
    }
  )

  # === バリデーション
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

  # === メソッド
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

  # 引数のトークンと、DBのダイジェストが一致するかどうかを返す
  def authenticated?(attribute, token)
    digest = self.send("#{attribute}_digest")
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end

  # ユーザを有効化する
  def activate
    transaction do
      update_attributes({ activated: true, activated_at: Time.zone.now })
    end
  end

  # アカウント有効化要求メールを送信する
  def send_activation_mail
    UserMailer.account_activation(self).deliver_now
  end

  # パスワード再設定用メールを送信する
  def send_password_reset_mail
    UserMailer.password_reset(self).deliver_now
  end

  # パスワード再設定用ダイジェストとトークンを発行する
  def create_reset_digest
    self.reset_token = User.new_token
    update_attributes(
      reset_digest: User.digest(self.reset_token),
      reset_sent_at: Time.zone.now,
    )
  end

  # パスワード再設定をリクエストしてからの猶予期間が過ぎているならtrueを返す
  def password_reset_expired?
    # 現在時刻より2時間以上過去なら猶予期間を過ぎているとみなす
    reset_sent_at < 2.hours.ago
  end

  # 自分自身と、フォローしているユーザのマイクロポストを取得する
  def feed
    # フォローしているユーザのIDを取得するための副問合せSQL
    following_ids = "
      select
        followed_id
      from
        #{FollowerFollowed.table_name}
      where
        follower_id = :user_id
    "

    # 自分自身と、フォローしているユーザのマイクロポストを取得する
    Micropost.where(
      "user_id = :user_id OR user_id IN (#{following_ids})",
      user_id: id,
    )
  end

  # 対象ユーザをフォローする
  def follow(other_user)
    # フォローしていない場合のみフォロー処理を行う
    unless following?(other_user)
      following << other_user
    end
  end

  # 対象ユーザをフォロー解除する
  def unfollow(other_user)
    following.delete(other_user)
  end

  # 対象ユーザがフォローしているならtrueを、していないならfalseを返す
  def following?(other_user)
    following.include?(other_user)
  end

  # ======================================
  private

  def down_email
    email.downcase!
  end

  # アカウント有効化ダイジェストとトークンを発行する
  def create_activation_digest
    self.activation_token = User.new_token
    self.activation_digest = User.digest(self.activation_token)
  end
end
