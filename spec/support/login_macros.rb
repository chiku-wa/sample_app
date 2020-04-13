module LoginMacros
  # ---
  # 所定の操作を行うメソッド(必要においじて期待値の確認も行う)
  #
  # ユーザ登録(サインアップ)フォームの入力を行うメソッド
  def input_user_form(user)
    fill_in("user[name]", with: user.name)
    fill_in("user[email]", with: user.email)
    fill_in("user[password]", with: user.password)
    fill_in("user[password_confirmation]", with: user.password_confirmation)
  end

  # ユーザ登録(サインアップ)フォームの入力を行うメソッド
  def input_login_form(user, remember_me: false)
    fill_in("sessions[email]", with: user.email)
    fill_in("sessions[password]", with: user.password)
    param_name_remember_me = "sessions[remember_me]"
    if remember_me
      check(param_name_remember_me)
    else
      uncheck(param_name_remember_me)
    end
  end

  # ログイン操作を行うメソッド
  def login_operation(user)
    visit login_path
    user = User.new(
      email: user.email,
      password: user.password,
    )
    input_login_form(user, remember_me: true)
    click_button("Log in")
  end

  # ログアウト操作を行うメソッド
  def logout_operation
    click_link("Account")
    click_link("Log out")
  end

  # ---
  # 期待値確認用メソッド
  #

  # ログイン済みの場合に表示される要素が表示されていること
  def display_login_menu
    # ログイン時のみ表示されるボタンが表示されていること
    expect(page).to(have_link("Users"))
    expect(page).to(have_link("Profile"))
    expect(page).to(have_link("Settings"))
    expect(page).to(have_link("Log out"))

    # 未ログイン時のみ表示するボタンが表示されていないこと
    expect(page).not_to(have_link("Log in"))
  end

  # 未ログインの場合に表示される要素が表示されていること
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
