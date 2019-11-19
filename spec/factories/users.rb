FactoryBot.define do
  factory :user, class: User do
    name { "Michael Example" }
    email { "michael@example.com" }
    password { "password" }
  end

  factory :user_second, class: User do
    name { "Yamada Tarou" }
    email { "yamada.tarou@example.com" }
    password { "123456" }
  end
end
