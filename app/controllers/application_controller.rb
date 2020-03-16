class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  # ===== すべてのControllerで共通的に使用するヘルパーメソッドのinclude
  # セッション(ログイン、ログアウト処理など)に関連するメソッド
  include SessionsHelper

  # ユーザがログイン済みでない場合、ログイン画面に遷移させるメソッド
  def logged_in_user
    unless logged_in?
      store_location
      flash[:danger] = "Please log in."
      redirect_to(login_path)
    end
  end
end
