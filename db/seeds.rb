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
# マイクロポスト登録
99.times do |i|
  user_admin.microposts.build(content: "Test content#{i}.")
end
user_admin.save

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

# 一部のユーザのみ、マイクロポストを50件登録する
users = User.order(created_at: :asc).take(3)
users.each do |u|
  50.times do |i|
    content = "#{Faker::Lorem.sentence} #{i}"
    u.microposts.build(content: content)
  end
  u.save
end
