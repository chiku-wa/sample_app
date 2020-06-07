FactoryBot.define do
  # Notice:同じcreated_atを持つレコードが生成されないようにテストデータを定義すること！

  # テストが実行されるたびに結果が変わってしまうことを防ぐために、時間を固定する
  latest_time = Time.zone.local(2020, 2, 1)

  factory :micropost_latest, class: Micropost do
    content { "Test message" }
    created_at { latest_time }
  end

  factory :micropost_5min_ago, class: Micropost do
    content { "Test message 5分前" }
    created_at { latest_time.ago(5.minutes) }
  end

  factory :micropost_10min_ago, class: Micropost do
    content { "Test message 10分前" }
    created_at { latest_time.ago(10.minutes) }
  end

  factory :micropost_2hours_ago, class: Micropost do
    content { "Test message 2時間前" }
    created_at { latest_time.ago(2.hours) }
  end

  factory :micropost_3years_ago, class: Micropost do
    content { "Test message 3年前" }
    created_at { latest_time.ago(3.years) }
  end

  factory :micropost_5years_ago, class: Micropost do
    content { "Test message 5年前" }
    created_at { latest_time.ago(5.years) }
  end
end
