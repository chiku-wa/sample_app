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
    session.delete(:user_id)
    @current_user = nil
  end
end
