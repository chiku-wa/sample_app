require "rails_helper"

RSpec.feature "Sessions", type: :feature do
  before "テストユーザ登録" do
    @user = FactoryBot.build(:user)
    @user.save
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

  # TODO:
  # 以下のテストはCookieを保持したままブラウザを開き直す処理が実装できていないためPending
  # Capybaraのドライバなどを選定し、実装する
  pending "remember_meにチェックを入れた状態ログインした場合、ブラウザを開き直してもログイン状態が保持されること" do
    visit login_path

    user = User.new(
      email: @user.email,
      password: @user.password,
    )
    input_login_form(user, remember_me: true)
    click_button("Log in")

    expect(page).to(have_title(full_title(@user.name)))

    display_login_menu

    # セッションを閉じて開き直してもログイン状態が保持されていること
    # puts page.methods.sort.join("\n") #.driver.browser.methods
    page.quit
    visit root_path
    page.refresh
    display_login_menu
  end
end
