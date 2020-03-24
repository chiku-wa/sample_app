class MicropostsController < ApplicationController
  before_action :logged_in_user, only: [:create, :destroy]

  # マイクロポストを新規登録するアクション
  def create
    @micropost = current_user.microposts.build(micropost_params)
    if @micropost.save
      flash[:success] = "Micropost created!"
      redirect_to(root_url)
    else
      # 保存に失敗した場合は、マイクロポスト投稿画面に遷移させる
      # ※root_urlを書き換えた場合に想定外の動きになるため、あえてコントローラ・アクションを明示する
      render("static_pages/home")
    end
  end

  # マイクロポストを削除するアクション
  def destroy
  end

  # ======================================
  private

  # クライアントから不正なパラメータをリクエストされないように、指定できるパラメータを制限するためのメソッド
  def micropost_params
    params.require(:micropost).permit(:content)
  end
end
