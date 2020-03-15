require "rails_helper"

RSpec.describe "MicropostsController-requests", type: :request do
  before "テストユーザ登録" do
    # --- マイクロソフトの取得順序テスト用のデータ
    @user = User.new(
      name: "Cacy",
      email: "cacy@example.com",
      password: "hogehoge",
      password_confirmation: "hogehoge",
    )
    [
      # テストを正確にするため、レコードの作成日時が古い順に登録する
      FactoryBot.build(:micropost_3years_ago),
      FactoryBot.build(:micropost_2hours_ago),
      FactoryBot.build(:micropost_10min_ago),
      FactoryBot.build(:micropost_latest),
    ].each do |m|
      @user.microposts.build(content: m.content, created_at: m.created_at)
    end
    @user.save
  end

  context "未ログインユーザのアクセスが許可されていないアクションのテスト" do
    it "未ログインの場合にマイクロポストを新規に登録しようとした場合はログインページに遷移すること" do
      micropost = Micropost.new(content: Faker::Lorem.sentence)
      post microposts_path, params: { micropost: params_micropost_update(micropost) }
      follow_redirect!

      expect(response).to(have_http_status("200"))
      assert_template "sessions/new"
    end

    it "未ログインの場合にマイクロポストを新規に登録しようとした場合はログインページに遷移すること" do
      delete micropost_path(@user.microposts.first.id)
      follow_redirect!

      expect(response).to(have_http_status("200"))
      assert_template "sessions/new"
    end
  end
end
