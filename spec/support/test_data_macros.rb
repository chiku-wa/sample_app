module TestDataMacros
  # 引数として渡した数だけUserデータを作成するメソッド
  def generate_test_users(number_of = 1)
    test_users = []
    number_of.times do |i|
      test_users << User.new(
        name: Faker::Name.name,
        email: "example-#{i}@railstutorial.org",
        password: "foobar",
        activated: true,
        activated_at: Time.zone.now,
      )
    end
    User.import(test_users)
  end
end
