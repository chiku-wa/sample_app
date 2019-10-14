class SessionsController < ApplicationController
  def new
  end

  def create
    recieve_email = params[:sessions][:email]
    recieve_password = params[:sessions][:password]

    user = User.find_by_email(recieve_email.downcase)

    # 該当するメールアドレスを持つユーザが存在し、パスワードも正しければログイン処理を行い、プロフィールを表示する。
    # そうでなければ、ログイン画面にエラーメッセージを表示して戻す。
    if user && user.authenticate(recieve_password)
      log_in(user)
      redirect_to user
    else
      flash.now[:danger] = "Invalid email/password combination"
      render "new"
    end
  end

  def destroy
    session.delete(:user_id)
  end
end
