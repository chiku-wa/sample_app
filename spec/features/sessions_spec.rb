require "rails_helper"

RSpec.feature "Sessions", type: :feature do
  before "テストユーザ登録" do
    @user = FactoryBot.build(:user)
    @user.save
  end

  feature "無効なログイン情報を入力" do
    scenario "他の画面に遷移してもエラーメッセージが表示されたままにならないこと" do
      visit login_path

      fill_in("sessions[email]", with: "invalid@foo.bar")
      fill_in("sessions[password]", with: "FooBar")

      # ログインフォーム画面でエラーが表示されること
      click_button("Log in")
      expect(page).to(have_selector(".alert.alert-danger", text: "Invalid email/password combination"))

      # ホーム画面に遷移したときはエラーが表示され【ない】こと
      # ヘッダのHomeリンクをクリック
      click_link("Home")
      expect(page).to_not(have_selector(".alert.alert-danger", text: "Invalid email/password combination"))

      # 未ログイン時のみ表示されるボタンが表示されていること
      expect(page).to(have_link("Log in"))

      # ログイン時のみ表示するボタンが表示されていないこと
      expect(page).not_to(have_link("Users"))
      expect(page).not_to(have_link("Profile"))
      expect(page).not_to(have_link("Settings"))
      expect(page).not_to(have_link("Log out"))
    end
  end

  feature "正常なログイン情報を入力" do
    scenario "ログイン後はプロフィール画面に遷移すること" do
      visit login_path

      fill_in("sessions[email]", with: @user.email)
      fill_in("sessions[password]", with: @user.password)

      click_button("Log in")

      expect(page).to(have_title(full_title(@user.name)))

      # ログイン時のみ表示されるボタンが表示されていること
      expect(page).to(have_link("Users"))
      expect(page).to(have_link("Profile"))
      expect(page).to(have_link("Settings"))
      expect(page).to(have_link("Log out"))

      # 未ログイン時のみ表示するボタンが表示されていないこと
      expect(page).not_to(have_link("Log in"))
    end
  end
end
