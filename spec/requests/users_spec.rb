require "rails_helper"

RSpec.describe "UsersController-requests", type: :request do
  before "テストユーザ登録" do
    @user = FactoryBot.build(:user)
    @user.save

    @user_second = FactoryBot.build(:user_second)
    @user_second.save

    @user_admin = FactoryBot.build(:user_admin)
    @user_admin.save

    generate_test_users(100)
  end

  context "未ログインユーザのアクセスが許可されていないページのテスト" do
    it "未ログインの場合にユーザ一覧を参照しようとした場合はログインページに遷移し、ログイン後はユーザ一覧画面に遷移すること" do
      get users_path
      follow_redirect!

      # ログインページに遷移すること
      expect(response).to(have_http_status("200"))
      assert_template "sessions/new"

      # ログインするとユーザ参照画面に遷移すること
      post login_path, params: { sessions: params_login(@user, remember_me: true) }
      follow_redirect!
      assert_template "users/index"

      # 記憶されたURLがリセットされていること
      expect(session[:forwarding_url]).to be_blank
    end

    it "未ログインの場合にユーザ情報を参照しようとした場合はログインページに遷移し、ログイン後はユーザ参照画面に遷移すること" do
      get user_path(@user)
      follow_redirect!

      # ログインページに遷移すること
      expect(response).to(have_http_status("200"))
      assert_template "sessions/new"

      # ログインするとユーザ参照画面に遷移すること
      post login_path, params: { sessions: params_login(@user, remember_me: true) }
      follow_redirect!
      assert_template "users/show"
      expect(assigns[:user].id).to eq @user.id

      # 記憶されたURLがリセットされていること
      expect(session[:forwarding_url]).to be_blank
    end

    it "ユーザ編集画面を表示しようした場合はログインページに遷移し、ログイン後はユーザ編集画面に遷移すること" do
      get edit_user_path(@user)
      follow_redirect!

      # ログインページに遷移すること遷移すること
      expect(response).to(have_http_status("200"))
      assert_template "sessions/new"

      # ログインするとユーザ編集画面に遷移すること
      post login_path, params: { sessions: params_login(@user, remember_me: true) }
      follow_redirect!
      assert_template "users/edit"

      # 記憶されたURLがリセットされていること
      expect(session[:forwarding_url]).to be_blank
    end

    it "ユーザを直接更新しようとした場合はログインページに遷移すること" do
      patch user_path(@user), params: { user: params_update(@user) }
      follow_redirect!

      expect(response).to(have_http_status("200"))
      assert_template "sessions/new"
    end
  end

  context "ユーザ一覧機能に関するテスト" do
    it "直接アクセス、Next、Previousが正常に機能すること" do
      post login_path, params: { sessions: params_login(@user, remember_me: true) }

      expect_number_of_one = User.where(activated: true).paginate(page: 1).each.size
      # 1ページに移動しても想定通りの件数が表示されること
      get users_path, params: { page: 1 }
      assert_template "users/index"
      expect(assigns[:users].size).to eq expect_number_of_one
      # ページ指定無しの場合は1ページ目を指定した場合と結果が同じであること
      get users_path, params: { page: nil }
      assert_template "users/index"
      expect(assigns[:users].size).to eq expect_number_of_one

      expect_number_of_two = User.where(activated: true).paginate(page: 2).each.size
      # 次のページに移動しても想定通りの件数であること
      get users_path, params: { page: 2 }
      assert_template "users/index"
      expect(assigns[:users].size).to eq expect_number_of_two
    end

    it "有効化されていないユーザが取得できないこと" do
      post login_path, params: { sessions: params_login(@user, remember_me: true) }

      # ページ指定無しの場合でも正常に表示されること
      get users_path, params: { page: nil }
      assert_template "users/index"

      # 有効化されていないユーザが取得できないこと
      expect(assigns[:users].where(activated: true).size).not_to eq 0
      expect(assigns[:users].where(activated: false).size).to eq 0
    end
  end

  context "ユーザ参照(プロフィール)画面に関するテスト" do
    it "ログインしたあとに自身のプロフィール画面に遷移すること" do
      post login_path, params: { sessions: params_login(@user, remember_me: true) }

      follow_redirect!
      assert_template "users/show"
      expect(assigns[:user].id).to eq @user.id
    end

    it "無効なユーザのプロフィールを閲覧しようとした場合はTOP画面に遷移すること" do
      # ログインする
      post login_path, params: { sessions: params_login(@user, remember_me: true) }
      @user.activated = false
      @user.save

      get user_path(@user)
      follow_redirect!
      assert_template "static_pages/home"
    end

    it "マイクロポストが更新日時の新しい順に表示されていること" do
      post login_path, params: { sessions: params_login(@user, remember_me: true) }

      follow_redirect!
      assert_template "users/show"

      # マイクロポストを登録する
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

      # 投稿日時の新しい順であることを確認する
      expect_first = FactoryBot.build(:micropost_latest)
      expect(assigns[:microposts][0].content).to eq expect_first.content
      expect(assigns[:microposts][0].created_at).to eq expect_first.created_at

      expect_second = FactoryBot.build(:micropost_10min_ago)
      expect(assigns[:microposts][1].content).to eq expect_second.content
      expect(assigns[:microposts][1].created_at).to eq expect_second.created_at

      expect_third = FactoryBot.build(:micropost_2hours_ago)
      expect(assigns[:microposts][2].content).to eq expect_third.content
      expect(assigns[:microposts][2].created_at).to eq expect_third.created_at

      expect_fourth = FactoryBot.build(:micropost_3years_ago)
      expect(assigns[:microposts][3].content).to eq expect_fourth.content
      expect(assigns[:microposts][3].created_at).to eq expect_fourth.created_at
    end
  end

  context "ユーザ更新機能に関するテスト" do
    it "ユーザが正常に更新されること" do
      # ログインする
      post login_path, params: { sessions: params_login(@user, remember_me: true) }

      # ユーザ更新画面に正常に遷移すること
      get edit_user_path(@user)
      expect(response).to(have_http_status("200"))
      assert_template "users/edit"

      # ユーザを更新
      modify_name = @user.name + "_modify"
      modify_email = "modify" + @user.email
      modify_password = "something_password"
      user_modify = User.new(
        name: modify_name,
        email: modify_email,
        password: modify_password,
        password_confirmation: modify_password,
      )
      patch user_path(@user), params: { user: params_update(user_modify) }

      # ユーザ情報が更新されていること
      user = User.find(@user.id)
      expect(user.name).to eq modify_name
      expect(user.email).to eq modify_email

      # 更新後のパスワードで認証できることを確認する
      expect(user.authenticate(modify_password)).to be_truthy

      # 更新に成功した場合はプロフィール画面に遷移すること
      follow_redirect!
      assert_template "users/show"
      expect(assigns[:user].id).to eq user.id
    end

    it "不正な値の場合はユーザが更新されないこと" do
      # ログインする
      post login_path, params: { sessions: params_login(@user, remember_me: true) }

      # ユーザ更新画面に正常に遷移すること
      get edit_user_path(@user)
      expect(response).to(have_http_status("200"))
      assert_template "users/edit"

      # 不正な値でユーザを更新
      invalid_email = @user.email + "invalid_password"
      user_modify = User.new(
        name: @user.name,
        email: invalid_email,
        password: @user.password,
        password_confirmation: @user.password,
      )
      patch user_path(@user), params: { user: params_update(user_modify) }

      # ユーザ情報が更新されていないこと
      user = User.find(@user.id)
      expect(user.name).to eq @user.name
      expect(user.email).to eq @user.email
      expect(user.password_digest).to eq @user.password_digest

      # 更新に失敗した場合は編集画面に遷移すること
      assert_template "users/edit"
    end

    it "別のユーザで編集画面に遷移しようとした場合はTOP画面に遷移すること" do
      # ユーザ1でログインする
      post login_path, params: { sessions: params_login(@user, remember_me: true) }

      # ユーザ2の更新画面に遷移するとTOP画面に遷移すること
      get edit_user_path(@user_second)

      follow_redirect!
      expect(response).to(have_http_status("200"))
      assert_template "static_pages/home"
    end

    it "別のユーザ情報を更新しようとした場合はTOP画面に遷移すること" do
      # ユーザ1でログインする
      post login_path, params: { sessions: params_login(@user, remember_me: true) }

      # ユーザ2の更新画面に遷移するとTOP画面に遷移すること
      patch user_path(@user_second), params: { user: params_update(@user) }

      follow_redirect!
      expect(response).to(have_http_status("200"))
      assert_template "static_pages/home"
    end

    it "PATCHリクエストでadmin属性を更新しようとしても更新されないこと" do
      post login_path, params: { sessions: params_login(@user, remember_me: true) }

      # adminパラメータを追加してPATCHリクエストを送信する
      invalid_parameter = params_update(@user)
      invalid_parameter[:admin] = true
      patch user_path(@user), params: { user: invalid_parameter }

      # 管理者権限が付与されていないこと
      @user.reload
      expect(@user.admin).to be_falsey

      # エラーにはならず、通常の更新と同じ様にユーザ情報画面に遷移すること
      follow_redirect!
      expect(response).to(have_http_status("200"))
      assert_template "users/show"
      expect(assigns[:user].id).to eq @user.id
    end
  end

  context "ユーザ削除機能に関するテスト" do
    it "正常にユーザが削除できること" do
      # 管理者ユーザでログインする
      post login_path, params: { sessions: params_login(@user_admin) }

      # ユーザが削除できること
      user = User.find_by(admin: false)
      expect {
        delete user_path(user)
      }.to change(User, :count).by(-1)

      expect(User.find_by(id: user.id)).to be_nil
    end
  end

  it "管理者以外がユーザを削除できないこと" do
    # 管理者以外のユーザでログインする
    post login_path, params: { sessions: params_login(@user) }

    # ユーザが削除されず、TOP画面に遷移すること
    expect {
      delete user_path(@user_second)
    }.to change(User, :count).by(0)
    expect(User.find_by(id: @user_second.id)).to eq @user_second

    follow_redirect!
    assert_template "static_pages/home"
  end
end
