module RequestMacros
  # ---
  # paramsの引数を生成するためのメソッド群
  #
  # Requestテストで使用するユーザ情報のハッシュを返す

  def params_user(user, remember_me: false)
    {
      name: user.name,
      email: user.email,
      password: user.password,
      remember_me: remember_me ? "1" : "0",
    }
  end
end
