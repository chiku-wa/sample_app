class MicropostsController < ApplicationController
  before_action :logged_in_user, only: [:create, :destroy]
  before_action :correct_user, only: [:destroy]

  # マイクロポストを新規登録するアクション
  def create
    @micropost = current_user.microposts.build(micropost_params)
    if @micropost.save
      flash[:success] = "Micropost created!"
      redirect_to(root_url)
    else
      # 保存に失敗した場合は、マイクロポスト投稿画面に遷移させる
      flash[:error] = @micropost.errors.full_messages
      redirect_to(root_url)
    end
  end

  # マイクロポストを削除するアクション
  def destroy
    @micropost.destroy
    flash[:success] = "Micropost deleted"

    # 直前まで見ていたページに遷移させる
    # 直前まで見ていたページが存在しない場合はTOP画面に遷移させる
    redirect_back(fallback_location: root_url)
  end

  # ======================================
  private

  # クライアントから不正なパラメータをリクエストされないように、指定できるパラメータを制限するためのメソッド
  def micropost_params
    params.require(:micropost).permit(:content, :picture)
  end

  # リクエストしたマイクロポストが、現在ログインしているユーザが保有しているものかをチェックし、
  # リクエストされたマイクロポストをインスタンス変数に格納する。
  # 保有していなければTOP画面に遷移させる。
  def correct_user
    @micropost = current_user.microposts.find_by(id: params[:id])
    if @micropost.nil?
      redirect_to(root_path)
    end
  end
end
