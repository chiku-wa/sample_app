class SessionsController < ApplicationController
  # ログインページを表示するためのアクション
  def new
  end

  # ログイン処理のアクション
  def create
    recieve_email = params[:sessions][:email]
    recieve_password = params[:sessions][:password]
    recieve_remember_me = params[:sessions][:remember_me]

    user = User.find_by_email(recieve_email.downcase)

    # 該当するメールアドレスを持つユーザが存在し、パスワードも正しければログイン処理を行い、プロフィールを表示する。
    # そうでなければ、ログイン画面にエラーメッセージを表示して戻す。
    if user && user.authenticate(recieve_password)
      log_in(user)

      # remember_meにチェックが入れられている場合のみ、記憶トークンを保存する
      if recieve_remember_me.to_i == 1
        remember(user)
      else
        forget(user)
      end

      redirect_back_or user
    else
      flash.now[:danger] = "Invalid email/password combination"
      render "new"
    end
  end

  # ログアウト処理のアクション
  def destroy
    # ログアウトし、TOP画面に遷移する
    log_out
    redirect_to root_url
  end
end
