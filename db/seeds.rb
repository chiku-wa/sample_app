User.create!(
  name: "Example User",
  email: "example@railstutorial.org",
  password: "123456",
  password_confirmation: "123456",
)

99.times do |i|
  name = Faker::Name.name
  email = "example-#{i}@railstutorial.org"
  password = "foobar"
  User.create!(
    name: name,
    email: email,
    password: password,
    password_confirmation: password,
  )
end
