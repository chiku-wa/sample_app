require "rails_helper"

RSpec.feature "PasswordResets", type: :feature do
  before "テストユーザ登録" do
    @user = FactoryBot.build(:user)
    @user.save
  end

  feature "パスワード再設定リクエスト用画面のテスト" do
    scenario "パスワード再設定リクエスト用画面に遷移できること" do
      visit users_path

      # ログイン画面に遷移し、パスワード再設定リクエスト用リンクをクリックする
      visit login_path
      click_link("forgot password")

      expect(page).to(have_title(full_title("Forgot password")))
    end
  end
end
