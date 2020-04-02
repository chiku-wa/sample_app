FactoryBot.define do
  # テストで使用する標準のユーザ
  factory :user, class: User do
    name { "Michael Example" }
    email { "michael@example.com" }
    password { "password" }
    activated { true }
    activated_at { Time.zone.now }
  end

  factory :user_inactive, class: User do
    name { "Inactive Tarou" }
    email { "inactive@example.com" }
    password { "password" }
    activated { false }
  end

  # 2人目のテストユーザ
  factory :user_second, class: User do
    name { "Yamada Tarou" }
    email { "yamada.tarou@example.com" }
    password { "123456" }
    activated { true }
    activated_at { Time.zone.now }
  end

  # 管理者ユーザ
  factory :user_admin, class: User do
    name { "Admin Tarou" }
    email { "admin.tarou@example.com" }
    password { "123456" }
    admin { true }
    activated { true }
    activated_at { Time.zone.now }
  end
end
