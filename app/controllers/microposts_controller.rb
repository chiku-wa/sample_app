class MicropostsController < ApplicationController
  before_action :logged_in_user, only: [:create, :destroy]

  # マイクロポストを新規登録するアクション
  def create
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
