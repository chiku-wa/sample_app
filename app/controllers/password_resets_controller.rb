class PasswordResetsController < ApplicationController

  # パスワード再設定リクエスト画面に遷移するアクション
  def new
  end

  # パスワード再設定用のトークン・ダイジェストを生成し、ユーザにメールを送信するアクション
  def create
    # リクエストされたメールアドレスを持つユーザを検索する
    @user = User.find_by(email: params[:password_reset][:email])

    # ユーザが存在しなければエラーを表示する
    unless @user
      flash.now[:danger] = "Email address not found."
      render "new" and return
    end

    # ユーザが有効でなければエラーを表示する
    unless @user.activated?
      flash.now[:danger] = "Account not enabled, please account activated."
      render "new"
      return
    end

    # 有効なユーザが見つかればパスワード再設定用リンクを送信する
    if @user
      @user.create_reset_digest
      @user.send_password_reset_mail

      flash.now[:success] = "Email sent with password reset instructions"
      render "new"
    end
  end

  # パスワード再設定用画面(メール本文からリンク)に遷移するアクション
  def edit
  end
end
