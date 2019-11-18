require "rails_helper"

RSpec.describe "UsersController-requests", type: :request do
  before "edit,showなどの既存ユーザが必要なアクションをテストするためにユーザ登録を行う" do
    @user = User.new(
      name: "Tom",
      email: "tom@example.com",
      password: "foobar",
      password_confirmation: "foobar",
    )
    @user.save
  end

  context "ログイン済みの場合にのみ、アクセスを許可されたページのテスト" do
    it "未ログインの場合にユーザ情報を参照しようとした場合はログインページに遷移すること" do
      get user_path(@user)
      follow_redirect!

      expect(response).to(have_http_status("200"))
      assert_template "sessions/new"
    end

    it "ユーザ編集画面を表示しようした場合はログインページに遷移すること" do
      get edit_user_path(@user)
      follow_redirect!

      expect(response).to(have_http_status("200"))
      assert_template "sessions/new"
    end

    it "ユーザを更新しようとした場合はログインページに遷移すること" do
      patch user_path(@user), params: { user: params_update(@user) }
      follow_redirect!

      expect(response).to(have_http_status("200"))
      assert_template "sessions/new"
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

    it "ユーザが正常に更新されること" do
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

      # 更新に失敗した場合はTOP画面に遷移すること
      assert_template "users/edit"
    end
  end
end
