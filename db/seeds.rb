# ===== 管理用ユーザ登録
# ユーザ登録
user_admin = User.create!(
  name: "Example User",
  email: "example@railstutorial.org",
  password: "123456",
  password_confirmation: "123456",
  admin: true,
  activated: true,
  activated_at: Time.zone.now,
)

# ===== テストユーザ登録
# ユーザ登録
users = []
99.times do |i|
  name = Faker::Name.name
  email = "example-#{i}@railstutorial.org"
  password = "foobar"
  users << User.new(
    name: name,
    email: email,
    password: password,
    password_confirmation: password,
    activated: true,
    activated_at: Time.zone.now,
  )
end
User.import(users)

# ---------- フォローとフォロワーの関係を作成し、マイクロポストを登録する
# フォローデータ関係を作成する
follower_users = User.order(id: :asc).take(3)
following_users = User.order(id: :desc).take(10)

follower_users.each do |follower_user|
  following_users.each do |following_user|
    follower_user.follow(following_user)
  end
end

# フォロワーのマイクロポストを登録する
follower_users.each do |u|
  50.times do |i|
    content = "#{Faker::Lorem.sentence} #{i}"
    u.microposts.build(content: content)
  end
  u.save
end

# フォローされているユーザのマイクロポストを登録する
following_users.each do |u|
  20.times do |i|
    content = "#{Faker::Lorem.sentence} #{i}"
    u.microposts.build(content: content)
  end
  u.save
end

# ---------- フォロー関係のない一部のユーザのマイクロポストを登録する
not_follow_users = User.where(
  "id NOT IN (:ids)",
  ids: (follower_users + following_users).map(&:id),
)
not_follow_users.take(3).each do |u|
  10.times do |i|
    content = "#{Faker::Lorem.sentence} #{i}"
    u.microposts.build(content: content)
  end
  u.save
end
