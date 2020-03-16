require "rails_helper"

RSpec.describe "MicropostsController-requests", type: :request do
  before "テストユーザ登録" do
    # --- マイクロソフトの取得順序テスト用のデータ
    @user = FactoryBot.build(:user)
    @user.save

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

  context "マイクロポストの新規登録に関するテスト" do
    it "正常に登録できること" do
      # ログインする
      post login_path, params: { sessions: params_login(@user, remember_me: true) }

      follow_redirect!
      assert_template "users/show"

      size_before_update = @user.microposts.size

      # 登録するとマイクロポストが1件登録されていること
      micropost = Micropost.new(content: Faker::Lorem.sentence)
      expect {
        post microposts_path, params: { micropost: params_micropost_update(micropost) }
      }.to change(Micropost, :count).by(1)

      # TOP画面に遷移すること
      follow_redirect!
      assert_template "static_pages/home"

      # ユーザに紐づくマイクロポストが登録されていること
      @user.reload
      expect(@user.microposts.size).to eq (size_before_update + 1)
    end

    it "Content以外の要素をリクエストで更新できないこと" do
      # ログインする
      post login_path, params: { sessions: params_login(@user, remember_me: true) }

      follow_redirect!
      assert_template "users/show"

      micropost = Micropost.new(content: Faker::Lorem.sentence)
      request_micropost_params = params_micropost_update(micropost)

      # 日付を明示して更新をリクエストする
      not_expect_created_at = Time.new(1990, 1, 1)
      request_micropost_params[:created_at] = not_expect_created_at
      post microposts_path, params: { micropost: request_micropost_params }

      # 指定した作成日時でマイクロポストが登録されていないこと
      expect(Micropost.where(created_at: not_expect_created_at).size).to eq 0
    end
  end

  context "マイクロポストの削除に関するテスト" do
    it "正常に削除できること" do
      # 登録する

      #
    end
  end

  context "未ログインユーザのアクセスが許可されていないアクションのテスト" do
    it "未ログインの場合にマイクロポストを新規に登録しようとした場合はログインページに遷移すること" do
      micropost = Micropost.new(content: Faker::Lorem.sentence)
      post microposts_path, params: { micropost: params_micropost_update(micropost) }
      follow_redirect!

      expect(response).to(have_http_status("200"))
      assert_template "sessions/new"
    end

    it "未ログインの場合にマイクロポストを削除しようとした場合はログインページに遷移すること" do
      delete micropost_path(@user.microposts.first.id)
      follow_redirect!

      expect(response).to(have_http_status("200"))
      assert_template "sessions/new"
    end
  end
end
