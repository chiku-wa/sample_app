require "rails_helper"

RSpec.describe "UsersController-requests", type: :request do
  before "edit,showなどの既存ユーザが必要なアクションをテストするためにユーザ登録を行う" do
    @user = FactoryBot.build(:user)
    @user.save

    @user_second = FactoryBot.build(:user_second)
    @user_second.save

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

      expect_number_of = 30

      # ページ指定無しの場合でも正常に表示されること
      get users_path, params: { page: nil }
      assert_template "users/index"
      expect(assigns[:users].size).to eq expect_number_of

      # 次のページに移動しても想定通りの値が表示されること
      get users_path, params: { page: 2 }
      assert_template "users/index"
      expect(assigns[:users].size).to eq expect_number_of

      # 前のページに移動しても想定通りの値が表示されること
      get users_path, params: { page: 1 }
      assert_template "users/index"
      expect(assigns[:users].size).to eq expect_number_of
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

      # パスワードの変更されたことを確認するために、変更前のパスワードを保存する
      before_password = User.find(@user.id).password_digest

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
      # パスワードは、更新前の値と一致していないことを確認する
      expect(user.password).not_to eq before_password

      # 更新に成功した場合はプロフィール画面に遷移すること
      follow_redirect!
      assert_template "users/show"
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
    end
  end
end
