require "rails_helper"

RSpec.feature "UsersIndex", type: :feature do
  before "テストユーザ登録" do
    # ログイン用ユーザ作成
    @user = FactoryBot.build(:user)
    @user.save

    @user_second = FactoryBot.build(:user_second)
    @user_second.save

    generate_test_users(100)
  end

  feature "ユーザ一覧に関するテスト" do
    scenario "ページネーションバーが2つ存在すること" do
      login_operation(@user)
      click_link("Account")
      click_link("Users")

      expect(page).to(have_link("Next →", count: 2))
      expect(page).to(have_link("← Previous", count: 2))
    end

    scenario "一度に表示されるユーザが30件であること" do
      # ログインし、ユーザ一覧画面に遷移する
      login_operation(@user)
      click_link("Account")
      click_link("Users")

      # ユーザ一覧で使用されているulの配下のliの数が想定どおりであること
      number_of_users_one = User.where(activated: true).paginate(page: 1).each.size
      expect_number_of_user(number_of_users_one)

      # 画面上部のNextを押下した場合に想定通りの結果が帰ってくること
      click_link("Next →", match: :first)
      number_of_users_two = User.where(activated: true).paginate(page: 2).each.size
      expect_number_of_user(number_of_users_two)
    end
  end

  # ======================================
  private

  # 画面上に表示されたユーザ数が想定通りであることを確認するメソッド
  def expect_number_of_user(number_of_users)
    within(:css, ".users") do
      expect(page).to(have_css("li", count: number_of_users))
    end
  end
end
