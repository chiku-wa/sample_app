class UsersController < ApplicationController
  before_action :logged_in_user, only: [
                                   :index,
                                   :show,
                                   :edit,
                                   :update,
                                   :destroy,
                                   :following,
                                   :followers,
                                 ]
  before_action :correct_user, only: [:edit, :update]
  before_action :admin_user, only: [:destroy]

  # ユーザ一覧を表示するアクション
  def index
    # 有効なユーザの一覧を表示する
    @users = User.where(activated: true).paginate(page: params[:page])
  end

  # ユーザプロフィールと、ユーザが投稿したマイクロポストを表示するアクション
  def show
    @user = User.find(params[:id])

    # 最新順にマイクロポストを表示する
    @microposts = @user.microposts
      .order(created_at: :desc)
      .paginate(page: params[:page])

    redirect_to(root_url) and return unless @user.activated
  end

  # サインアップ(ユーザ新規作成)画面を表示するアクション
  def new
    @user = User.new
  end

  # ユーザを新規作成するアクション
  def create
    @user = User.new(user_params)
    if @user.save
      @user.send_activation_mail
      flash[:info] = "Please check your email to activate your account."
      redirect_to(root_url)
    else
      flash[:error] = @user.errors.full_messages
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
      flash[:error] = @user.errors.full_messages
      render("edit")
    end
  end

  # ユーザを削除するアクション
  def destroy
    if User.find(params[:id]).destroy
      flash[:success] = "User deleted"
      redirect_to users_path
    end
  end

  # フォローしているユーザ一覧を表示するアクション
  def following
    @user = User.find(params[:id])
    @title = "Following"
    @users = @user.following.paginate(page: params[:page])
    render("show_follow")
  end

  # フォロワー一覧を表示するアクション
  def followers
    @user = User.find(params[:id])
    @title = "Followers"
    @users = @user.followers.paginate(page: params[:page])
    render("show_follow")
  end

  # ======================================
  private

  # クライアントから不正なパラメータをリクエストされないように、指定できるパラメータを制限するためのメソッド
  def user_params
    # permitメソッドの引数に渡した名称のパラメータしか指定できない
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end

  # ログインユーザと異なるユーザに対するリクエストだった場合はTOP画面に遷移させるメソッド
  def correct_user
    @user = User.find(params[:id])
    unless current_user == @user
      redirect_to(root_path)
    end
  end

  # 管理者でない場合はTOP画面に遷移させる
  def admin_user
    unless current_user.admin?
      redirect_to(root_path)
    end
  end
end
