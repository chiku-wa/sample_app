class AccountActivationsController < ApplicationController
  # ユーザに送ったメール本文の有効化リンクをクリックしたときのアクション
  def edit
    user = User.find_by(email: params[:email])

    if user && !user.activated? && user.authenticated?(:activation, params[:id])
      # ユーザの有効化
      user.activate

      # ログインしてプロフィール画面に遷移する
      log_in(user)
      flash[:success] = "Account activated!"
      redirect_to(user)
    else
      flash[:danger] = "Invalid activstion link!"
      redirect_to(root_url)
    end
  end
end
