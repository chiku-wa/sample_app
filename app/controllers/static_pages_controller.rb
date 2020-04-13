class StaticPagesController < ApplicationController
  def home
    if logged_in?
      # ログインしている場合のみ以下を実施する
      # ・マイクロポスト投稿画面用フォームを表示するためのインスタンス変数を生成
      # ・自分と、フォローしている人のマイクロポスト一覧を表示するためののインスタンス変数の生成
      # [ToDo]フォロー中のユーザのマイクロポスト投稿機能を実装すること、実装次第この行コメント削除
      @micropost = current_user.microposts.build
      @feed_items = current_user.feed
        .order(created_at: :desc)
        .paginate(page: params[:page])
    end
  end

  def help
  end

  def about
  end
end
