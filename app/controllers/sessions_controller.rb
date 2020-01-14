class SessionsController < ApplicationController
  # ログインページを表示するためのアクション
  def new
  end

  # ログイン処理のアクション
  def create
    recieve_email = params[:sessions][:email]
    recieve_password = params[:sessions][:password]
    recieve_remember_me = params[:sessions][:remember_me]

    # 該当するメールアドレスを持つユーザが存在し、パスワードも正しければログイン処理を行う
    # 有効化されているユーザの場合のみログイン処理を行う
    user = User.find_by_email(recieve_email.downcase)
    if user && user.authenticate(recieve_password)
      if user.activated?
        log_in(user)

        # remember_meにチェックが入れられている場合のみ、記憶トークンを保存する
        # チェックが入れられていない場合は記憶トークンを削除する
        if recieve_remember_me.to_i == 1
          remember(user)
        else
          forget(user)
        end

        redirect_back_or user
      else
        flash[:warning] = "Account not activated.Check your email for the activation link."
        redirect_to(root_url)
      end
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
