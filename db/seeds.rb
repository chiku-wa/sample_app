# 管理用ユーザ登録
User.create!(
  name: "Example User",
  email: "example@railstutorial.org",
  password: "123456",
  password_confirmation: "123456",
)

# テストユーザ登録
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
  )
end
User.import(users)
