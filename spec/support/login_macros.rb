module LoginMacros
  # ---
  # フォーム入力用メソッド
  #
  def input_signup_form(user)
    fill_in("user[name]", with: user.name)
    fill_in("user[email]", with: user.email)
    fill_in("user[password]", with: user.password)
    fill_in("user[password_confirmation]", with: user.password_confirmation)
  end

  # ---
  # 期待値確認用メソッド
  #
  def display_login_menu
    # ログイン時のみ表示されるボタンが表示されていること
    expect(page).to(have_link("Users"))
    expect(page).to(have_link("Profile"))
    expect(page).to(have_link("Settings"))
    expect(page).to(have_link("Log out"))

    # 未ログイン時のみ表示するボタンが表示されていないこと
    expect(page).not_to(have_link("Log in"))
  end

  def display_logout_menu
    # 未ログイン時のみ表示されるボタンが表示されていること
    expect(page).to(have_link("Log in"))

    # ログイン時のみ表示するボタンが表示されていないこと
    expect(page).not_to(have_link("Users"))
    expect(page).not_to(have_link("Profile"))
    expect(page).not_to(have_link("Settings"))
    expect(page).not_to(have_link("Log out"))
  end
end
