module SessionsHelper

  # 渡されたユーザでログインする
  def log_in(user)
    session[:user_id] = user.id
  end

  def remember(user)
    # 記憶トークン発行し、暗号化してDBに登録
    user.remember

    # ユーザIDと記憶トークン(平文)をCookieに格納
    cookies.permanent.signed[:user_id] = user.id
    cookies.permanent[:remember_token] = user.remember_token
  end

  def forget(user)
    # DBに登録された記憶トークン(暗号化済み)を破棄
    user.forget

    # Cookie上のユーザIDと記憶トークン(平文)を破棄
    cookies.delete(:user_id)
    cookies.delete(:remember_token)
  end

  def current_user
    if session[:user_id]
      # セッションが存在する場合は、ログイン済みとみなしUserインスタンスを返す
      @current_user ||= User.find_by(id: session[:user_id])
    elsif cookies.signed[:user_id]
      # セッションが存在せず、CookieにユーザIDと、正しい記憶トークンが登録されていれば
      # ログイン処理を行う
      user = User.find_by(id: cookies.signed[:user_id])
      if user && user.authenticated?(cookies[:remember_token])
        log_in(user)
        @current_user = user
      end
    end
  end

  def logged_in?
    !!current_user
  end

  def log_out
    # current_userがnilだとエラーになるため、ログインしている場合のみforget処理を行う
    if logged_in?
      forget(current_user)
    end
    session.delete(:user_id)
    @current_user = nil
  end

  # セッションに記憶したURLにリダイレクトする、記憶したURLが存在しない場合は引数のURLにリダイレクトする
  # リダイレクトした後は、セッションに記憶したURLを抹消する
  def redirect_back_or(default)
    redirect_to(session[:forwarding_url] || default)
    session.delete(:forwarding_url)
  end

  # セッションにURLを記憶する
  def store_location
    # GETメソッドの場合のみ、記憶する
    if request.get?
      session[:forwarding_url] = request.original_url
    end
  end
end
