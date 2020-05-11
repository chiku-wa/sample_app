module TestDataMacros
  # 引数として渡した数だけUserデータを作成するメソッド
  # 有効されている/されていないユーザを登録する
  def generate_test_users(number_of = 1)
    test_users = []
    number_of.times do |i|
      test_users << User.new(
        name: Faker::Name.name,
        email: "example-#{i}@railstutorial.org",
        password: "foobar",
        activated: i.even? ? true : false,
        activated_at: Time.zone.now,
      )
    end
    User.import(test_users)
    test_users
  end

  # 第1引数の数だけユーザを作成し、第2引数として渡したユーザがそれらのユーザをフォローするメソッド
  def generate_followed_users(followed_user_number_of:, follower_user:)
    followed_user_number_of.times do |i|
      followed_user = User.new(
        name: Faker::Name.name,
        email: "example-#{i}@railstutorial.org",
        password: "foobar",
        activated: i.even? ? true : false,
        activated_at: Time.zone.now,
      )
      followed_user.save
      follower_user.follow(followed_user)
    end
  end

  # 第1引数の数だけユーザを作成し、第2引数として渡したユーザをフォローするる
  def generate_follower_users(follower_user_number_of:, followed_user:)
    follower_user_number_of.times do |i|
      follower_user = User.new(
        name: Faker::Name.name,
        email: "example-#{i}@railstutorial.org",
        password: "foobar",
        activated: i.even? ? true : false,
        activated_at: Time.zone.now,
      )
      follower_user.save
      follower_user.follow(followed_user)
    end
  end
end
