module RequestMacros
  # ---
  # paramsの引数を生成するためのメソッド群
  #

  # ログインのテストで使用するユーザ情報のハッシュを返す
  def params_login(user, remember_me: false)
    {
      name: user.name,
      email: user.email,
      password: user.password,
      remember_me: remember_me ? "1" : "0",
    }
  end

  # ユーザ更新用のユーザ情報のハッシュを返す
  def params_user_update(user)
    {
      name: user.name,
      email: user.email,
      password: user.password,
      password_confirmation: user.password_confirmation,
    }
  end

  # マイクロポスト更新用のマイクロポストハッシュを返す
  def params_micropost_update(micropost)
    {
      content: micropost.content,
    }
  end
end
