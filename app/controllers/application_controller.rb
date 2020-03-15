class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
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
