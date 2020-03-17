class StaticPagesController < ApplicationController
  def home
    if logged_in?
      # ログインしている場合のみ、マイクロポスト投稿画面用フォームを表示するためのインスタンス変数を生成する
      @micropost = current_user.microposts.build
    end
  end

  def help
  end

  def about
  end
end
