class FollowerFollowedsController < ApplicationController
  before_action :logged_in_user, only: [:create, :destroy]

  # ユーザをフォローするアクション
  def create
    # 対応するJavaScriptからUserインスタンスを呼び出すために、インスタンス変数に格納する
    @user = User.find_by(id: params[:followed_id])

    if @user
      # フォローする
      current_user.follow(@user)

      # HTMLフォームによる通信ならプロフィール画面をリダイレクト表示し、Ajaxによる非同期通信なら
      # 対応するJavaScriptを呼び出す
      respond_to do |format|
        format.html { redirect_to(user_path(@user)) }
        format.js
      end
    else
      redirect_to(root_path)
    end
  end

  # ユーザをフォロー解除するアクション
  def destroy
    # 対応するJavaScriptからUserインスタンスを呼び出すために、インスタンス変数に格納する
    @user = User.find_by(id: params[:id])

    if @user
      # フォロー解除する
      current_user.unfollow(@user)

      # HTMLフォームによる通信ならプロフィール画面をリダイレクト表示し、Ajaxによる非同期通信なら
      # 対応するJavaScriptを呼び出す
      respond_to do |format|
        format.html { redirect_to(user_path(@user)) }
        format.js
      end
    else
      redirect_to(root_path)
    end
  end
end
