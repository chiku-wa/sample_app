FactoryBot.define do
  # テストで使用する標準のユーザ
  factory :user, class: User do
    name { "Michael Example" }
    email { "michael@example.com" }
    password { "password" }
  end

  # 別セッション用のテストで使用するユーザ
  factory :user_second, class: User do
    name { "Yamada Tarou" }
    email { "yamada.tarou@example.com" }
    password { "123456" }
  end
end
