require "rails_helper"

RSpec.feature "Sessions", type: :feature do
  before "テストユーザ登録" do
    @user = FactoryBot.build(:user)
    @user.save

    @user_inactive = FactoryBot.build(:user_inactive)
    @user_inactive.save
  end

  feature "正常なログイン情報を入力" do
    scenario "remember_meにチェックを入れた状態ログインした場合、正常にログインが完了し、プロフィール画面が表示されること" do
      visit login_path

      user = User.new(
        email: @user.email,
        password: @user.password,
      )
      input_login_form(user, remember_me: true)
      click_button("Log in")

      expect(page).to(have_title(full_title(@user.name)))

      display_login_menu
    end

    scenario "remember_meにチェックを入れていない状態で、ログイン後はプロフィール画面に遷移すること" do
      visit login_path

      user = User.new(
        email: @user.email,
        password: @user.password,
      )
      input_login_form(user, remember_me: false)
      click_button("Log in")

      expect(page).to(have_title(full_title(@user.name)))

      display_login_menu
    end

    scenario "有効化されていないユーザでログインしようとするとTOP画面に遷移すること" do
      visit login_path

      user_inactive = User.new(
        email: @user_inactive.email,
        password: @user_inactive.password,
      )
      input_login_form(user_inactive, remember_me: false)
      click_button("Log in")

      # TOP画面に遷移し、メッセージが表示されること
      expect(page).to(have_title(full_title))
      expect(page).to(have_selector(".alert.alert-warning", text: "Account not activated.Check your email for the activation link."))

      display_logout_menu
    end
  end

  feature "無効なログイン情報を入力" do
    scenario "他の画面に遷移してもエラーメッセージが表示されたままにならないこと" do
      visit login_path

      user = User.new(
        email: "invalid@foo.bar",
        password: "FooBar",
      )
      input_login_form(user)
      click_button("Log in")

      # ログインフォーム画面でエラーが表示されること
      expect(page).to(have_selector(".alert.alert-danger", text: "Invalid email/password combination"))

      # ホーム画面に遷移したときはエラーが表示され【ない】こと
      # ヘッダのHomeリンクをクリック
      click_link("Home")
      expect(page).to_not(have_selector(".alert.alert-danger", text: "Invalid email/password combination"))

      # 未ログイン時のみ表示されるボタンが表示されていること、ログイン時のみ表示するボタンが表示されていないこと
      display_logout_menu
    end
  end

  feature "ログアウト" do
    scenario "ログアウトボタン押下後はセッションが破棄されること" do
      visit login_path

      # ログインする
      fill_in("sessions[email]", with: @user.email)
      fill_in("sessions[password]", with: @user.password)
      click_button("Log in")
      display_login_menu

      # ログアウトする
      click_link("Log out")

      expect(page).to(have_title(full_title))
      display_logout_menu
    end
  end
end
