class PasswordResetsController < ApplicationController
  before_action :get_user, only: [:edit, :update]
  before_action :valid_user, only: [:edit, :update]
  before_action :check_password_reset_expiration, only: [:edit, :update]

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
    @user = User.find_by(email: params[:email])
    unless (@user &&
            @user.activated? &&
            @user.authenticated?(:reset, params[:id]))
      redirect_to root_path
    end
  end

  # パスワードを再設定するアクション
  def update
    recieve_password = params[:user][:password]

    # パスワードが未設定なら、パスワード再設定画面に遷移する
    # ※空白文字の場合はValidationを通過しないため、個別にチェックする
    if recieve_password.blank?
      flash.now[:danger] = "Password is empty."
      @user.errors.add(:password, :blank)
      render "edit" and return
    end

    if @user.update_attributes(user_params)
      # 更新が成功したらログインした状態にしてプロフィール画面に遷移する。
      log_in(@user)
      flash[:success] = "Password has been reset."
      redirect_to(@user)
    else
      # 失敗した場合(Validationを通羽化しなかった場合)は再度パスワード再設定用ページに遷移する
      render "edit" and return
    end
  end

  # ======================================
  private

  # クライアントから不正なパラメータをリクエストされないように、指定できるパラメータを制限するためのメソッド
  def user_params
    # permitメソッドの引数に渡した名称のパラメータしか指定できない
    params.require(:user).permit(:password, :password_confirmation)
  end

  # パラメータとして受け取ったメールアドレスでユーザを検索してインスタンス変数に格納するメソッド
  def get_user
    @user = User.find_by(email: params[:email])
  end

  # 該当するメールアドレスを持たない or 有効でない or トークンが一致しない場合はTOP画面に遷移するメソッド
  def valid_user
    unless (@user &&
            @user.activated? &&
            @user.authenticated?(:reset, params[:id]))
      redirect_to root_path
    end
  end

  # パスワード再設定リクエストを出してから一定の期間が過ぎていた場合は、
  # パスワード再設定リクエスト用画面を表示する
  def check_password_reset_expiration
    if @user.password_reset_expired?
      flash[:danger] = "The URL has expired. Please reset your password again."
      redirect_to new_password_reset_path
    end
  end
end
