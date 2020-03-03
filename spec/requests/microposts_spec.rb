require "rails_helper"

RSpec.describe "MicropostsController-requests", type: :request do
  before "テストユーザ登録" do
    # --- マイクロソフトの取得順序テスト用のデータ
    @user_second = User.new(
      name: "Cacy",
      email: "cacy@example.com",
      password: "hogehoge",
      password_confirmation: "hogehoge",
    )
    # 最新日時のレコードは評価に使用するためインスタンス変数に格納
    @micropost_latest = FactoryBot.build(:micropost_latest)
    [
      # テストを正確にするため、レコードの作成日時が古い順に登録する
      FactoryBot.build(:micropost_3years_ago),
      FactoryBot.build(:micropost_2hours_ago),
      FactoryBot.build(:micropost_10min_ago),
      @micropost_latest,
    ].each do |m|
      @user_second.microposts.build(content: m.content, created_at: m.created_at)
    end
    @user_second.save
  end

  pending "一覧のテスト" do
    pending "ユーザに紐づく投稿が、登録日時の最新順に取得できること" do
    end
  end
end
