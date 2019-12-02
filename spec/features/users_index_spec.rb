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
    scenario "一度に表示されるユーザが30件であること" do

      # ログインし、ユーザ一覧画面に遷移する
      login_operation(@user)
      click_link("Account")
      click_link("Users")

      # ユーザ一覧で使用されているulの配下のliの数が想定どおりであること
      number_of_users = 30
      expect_number_of_user(number_of_users)

      # 画面上部のNextを押下しても同様に30件表示されること
      click_link("Next →", match: :first)
      expect_number_of_user(number_of_users)
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
