class UsersController < ApplicationController
  before_action :logged_in_user, only: [:show, :edit, :update]

  # ユーザプロフィール画面を表示するアクション
  def show
    @user = User.find(params[:id])
  end

  # サインアップ(ユーザ新規作成)画面を表示するアクション
  def new
    @user = User.new
  end

  # ユーザを新規作成するアクション
  def create
    @user = User.new(user_params)
    if @user.save
      log_in(@user)
      flash[:success] = "Welcome to the Sample App!"
      redirect_to(@user)
    else
      render("new")
    end
  end

  # ユーザ編集画面を表示するアクション
  def edit
    if logged_in?
      @user = User.find_by(id: session[:user_id])
    else
      redirect_to root_path
    end
  end

  # ユーザを更新するアクション
  def update
    @user = User.find_by(id: session[:user_id])
    if @user.update_attributes(user_params)
      flash[:success] = "Profile updated"
      redirect_to(@user)
    else
      render("edit")
    end
  end

  private

  # パラメータとしてリクエストされたユーザ情報を適切な形式にして返すメソッド
  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end

  # ユーザがログイン済みでない場合、ログイン画面に遷移させるメソッド
  def logged_in_user
    unless logged_in?
      flash[:danger] = "Please log in."
      redirect_to(login_path)
    end
  end
end
