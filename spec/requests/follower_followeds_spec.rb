require "rails_helper"

RSpec.describe "FollowerFollowedController-requests", type: :request do
  before "テストユーザ登録" do
    # ------ テスト用のユーザ、フォロー関係を登録する
    # * follower_user ー(フォロー)→ followed_user,followed_user_second
    # * follower_user ←(相互フォロー)→ follow_each_other_user
    # * independent_user ※フォローもフォロワーもなし
    @follower_user = FactoryBot.build(:follower_user)
    @follower_user.save
    @followed_user = FactoryBot.build(:followed_user)
    @followed_user.save
    @independent_user = FactoryBot.build(:user)
    @independent_user.save

    @follower_user.follow(@followed_user)
  end

  context "未ログインユーザのアクセスが許可されていないアクションのテスト" do
    it "未ログインの場合にフォローしようとした場合はログインページに遷移し、ログイン後はフォローを行わずプロフィール画面に遷移すること" do
      # ログインせずにフォローしようとする
      post follower_followeds_path, params: { followed_id: @independent_user.id }
      follow_redirect!

      # ログインページに遷移すること
      expect(response).to(have_http_status("200"))
      assert_template "sessions/new"

      # ログインするとユーザプロフィール画面に遷移すること
      post login_path, params: { sessions: params_login(@follower_user, remember_me: true) }
      follow_redirect!
      assert_template "users/show"
      expect(assigns[:user].id).to eq @follower_user.id

      # フォローされていないこと
      expect(@follower_user.following?(@independent_user)).to be_falsey

      # 記憶されたURLがリセットされていること
      expect(session[:forwarding_url]).to be_blank
    end

    it "未ログインの場合にフォロー解除しようとした場合はログインページに遷移し、ログイン後はフォロー解除を行わずプロフィール画面に遷移すること" do
      # ログインせずにフォローしようとする
      delete follower_followed_path(@followed_user.id)
      follow_redirect!

      # ログインページに遷移すること
      expect(response).to(have_http_status("200"))
      assert_template "sessions/new"

      # ログインするとユーザプロフィール画面に遷移すること
      post login_path, params: { sessions: params_login(@follower_user, remember_me: true) }
      follow_redirect!
      assert_template "users/show"
      expect(assigns[:user].id).to eq @follower_user.id

      # フォロー解除されていないこと
      expect(@follower_user.following?(@followed_user)).to be_truthy

      # 記憶されたURLがリセットされていること
      expect(session[:forwarding_url]).to be_blank
    end
  end

  context "フォロー機能に関するテスト" do
    it "ユーザをフォローすることができ、フォロー後はそのユーザのプロフィール画面に遷移すること" do
      # ログインする
      post login_path, params: { sessions: params_login(@follower_user, remember_me: true) }
      follow_redirect!

      target_user = @independent_user

      # まだフォローしていないこと
      expect(@follower_user.following?(target_user)).to be_falsey

      # フォローする
      expect {
        post follower_followeds_path, params: { followed_id: target_user.id }
      }.to change(FollowerFollowed, :count).by(1)

      # フォローできていること
      expect(@follower_user.following?(target_user)).to be_truthy
    end

    it "連続でフォローしてもエラーにならず、そのユーザのプロフィール画面に遷移すること" do
      # ログインする
      post login_path, params: { sessions: params_login(@follower_user, remember_me: true) }
      follow_redirect!

      # すでにフォロー済みのユーザであること
      target_user = @followed_user
      expect(@follower_user.following?(target_user)).to be_truthy

      # フォローしてもエラーにならず、プロフィール画面に遷移すること
      post follower_followeds_path, params: { followed_id: target_user.id }
      follow_redirect!
      expect(response).to(have_http_status("200"))

      # フォロー状態が維持できていること
      expect(@follower_user.following?(target_user)).to be_truthy
    end
  end

  context "フォロー解除機能に関するテスト" do
    it "フォロー済みのユーザの場合はフォロー解除することができ、フォロー解除後はそのユーザのプロフィール画面に遷移すること" do
      # ログインする
      post login_path, params: { sessions: params_login(@follower_user, remember_me: true) }
      follow_redirect!

      target_user = @followed_user

      # すでにフォロー済みであること
      expect(@follower_user.following?(target_user)).to be_truthy

      # フォロー解除する
      expect {
        delete follower_followed_path(target_user)
      }.to change(FollowerFollowed, :count).by(-1)

      # フォロー解除されていること
      expect(@follower_user.following?(target_user)).to be_falsey
    end

    it "連続でフォロー解除ししてもエラーにならず、そのユーザのプロフィール画面に遷移すること" do
      # ログインする
      post login_path, params: { sessions: params_login(@follower_user, remember_me: true) }
      follow_redirect!

      # フォローしていないユーザであること
      target_user = @independent_user
      expect(@follower_user.following?(target_user)).to be_falsey

      # フォロー解除してもエラーにならず、プロフィール画面に遷移すること
      delete follower_followed_path(target_user)
      follow_redirect!
      expect(response).to(have_http_status("200"))

      # フォロー解除状態が維持できていること
      expect(@follower_user.following?(target_user)).to be_falsey
    end
  end
end
