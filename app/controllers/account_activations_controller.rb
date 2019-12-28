class AccountActivationsController < ApplicationController
  def edit
    user = User.find_by(email: params[:email])

    # ユーザに送ったメール本文の有効化リンクをクリックしたときのアクション
    if !user.activated? && user.authenticated?(:activation, params[:id])
      # ユーザの有効化
      user.transaction do
        user.update_attribute(:activated, true)
        user.update_attribute(:activated_at, Time.zone.now)
      end

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
