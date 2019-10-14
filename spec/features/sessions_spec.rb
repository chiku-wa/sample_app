require "rails_helper"

RSpec.feature "Sessions", type: :feature do
  before "正常にログインできることを確認するためのテストユーザ登録" do
    # @user = User.new(
    #   name: "Alice",
    #   email: "alice@example.com",
    #   password: "foobar",
    #   password_confirmation: "foobar",
    # )
    # @user.save
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
    end
  end

  feature "正常なログイン情報を入力" do
    scenario "ログイン後はプロフィール画面に遷移すること" do
      visit login_path

      fill_in("sessions[email]", with: @user.email)
      fill_in("sessions[password]", with: @user.password)

      click_button("Log in")

      expect(page).to(have_title(full_title(@user.name)))
    end
  end
end
